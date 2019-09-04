function CaveFly()
% Feedback controler for a 2D race course
% Version 1.1 Created by S. Shroff Modified 8/24/19
% Goal: Design a controler to determine vertical force

%% Load Flyer Neural Network Parameters:
global W b
load('flyerParamsBest.mat', 'flyer')
W = flyer.W;
b = flyer.b;

%evolveNN(43);

%% Modifiable setup parameters
SYS = [];
SYS.tframe = 0.01;  % how fast to try to update frames (visual effect only, does not affect calculations)
SYS.level = 10;  % choose a level (any integer)

% Program steps
SYS = GenerateLevel(SYS);  % generates level
SYS = CalculateShipPath(SYS);  % calculates ship path based on controller 
t = SYS.Iimpact  % returns initial impact
AnimateShip(SYS) % animates the ship path
end 


%% Put your Controller code here

function F = ShipController(yWall1, yWall2, yShip, vyShip)

% Goal - use the input variables to calcuale a desired output force F.

% yWall1:  a 1 x 5 vector with positions of the top wall.  yWall1(5) is the furthest from the ship.
% yWall2:  a 1 x 5 vector with positions of the bottom wall.  yWall2(5) is the furthest from the ship.
% yShip: Current position of the ship
% vyShip: Current velocity of the ship
% F: Output force to apply in the vertical direction (can be -2 <= F <= 2, code will enforce this)
% 
% Note that the ship x velocity is 1 m/s, and the simulation time step is 1 second
% Press control+c to break the code

    A = sqrt((0:4).^2 + (yWall1(1:5) - yShip).^2); % ~Distance to all points on top wall
    B = sqrt((0:4).^2 + (yShip - yWall2(1:5)).^2); % ~Distance to all points on bottom wall
    
    persistent prevA prevB
    if isempty(prevA)
       prevA = A;
       prevB = B;
    end
    
    % 5-Way PID-approximating Neural Network
    global W %                                      - Network Weights (external)
    global b %                                      - Network Biases (external)
    LReLU = @(z) max(0.01*z,z); %                   - Leaky Rectified Linear Unit.
    x = [A,B, prevA,prevB]'; %                       - Network Inputs
    a1 = LReLU( W{:,:,1}*x + b{:,1} ); %            - Hidden Layer 1
    a2 = LReLU( W{:,:,2}*a1 + b{:,2} ); %           - Hidden Layer 2
    y = LReLU( W{:,:,3}*a2 + b{:,3} ); %            - Network Output
    
    prevA = A;
    prevB = B;

    F = 1000000*y;

end

% Employs a Genetic Algorithm to Evolve Neural Network's Parameters where
% Each Generation has a Population of N
function evolveNN(N)
    global W b % Link to External Network Parameters used by #ShipController
    
    % Generate Initial Population:
    pop = arrayfun(@Flyer, 1:N, 'UniformOutput', false); pop = [pop{:}];
    gen = 1; % Generation Number
    
    % Initialize Plot of Progress:
    eliteTimes = [0];
    avgTimes = [0];
    plotGenerations = [0];
    figure();
    hold on
        elitePlot = plot(eliteTimes,plotGenerations, 'r');
        avgPlot = plot(avgTimes,plotGenerations, 'k');
    hold off
    title({'CaveFlyer Neural Network Parameter Evolution Progress', char("with Generation Size of "+N+".")}, 'Interpreter', 'latex');
    xlabel('Generation', 'Interpreter', 'latex');
    ylabel('Time Survived [s]', 'Interpreter', 'latex');
    legend({'Best Member of Population', 'Average of Population'}, 'location', 'NorthWest', 'Interpreter', 'latex');
    
    while(pop(1).time < 10000) % Time of Best Performing Member of the Population
        % Test Each Flyer:
        i = 1;
        while(i <= N)
            for j=1:2
                % Setup Testing Environment
                SYS = [];
                SYS.tframe = 0.01;  % how fast to try to update frames (visual effect only, does not affect calculations)
                SYS.level = 5*j;  % choose a level (any integer)

                % Link External Network Params to the Flyer being Tested:
                W = pop(i).W;
                b = pop(i).b;

                % Conduct Test:
                SYS = GenerateLevel(SYS);  % generates level
                SYS = CalculateShipPath(SYS);  % calculates ship path based on controller
                pop(i).time = pop(i).time + SYS.Iimpact;  % returns initial impact
            end
            pop(i).time = pop(i).time / 2;
            
            i = i+1;
        end
        
        % Sort Flyers by Performance:
        [~, ind] = sort([pop.time], 'descend');
        pop = pop(ind);
        
        % Plot Progress Every 10 Generations:
        if( ~mod(gen,1) )
            eliteTimes(end+1) = pop(1).time;
            avgTimes(end+1) = mean([pop.time]);
            plotGenerations(end+1) = gen;
            
            set(elitePlot, 'XData',plotGenerations, 'YData',eliteTimes);
            set(avgPlot, 'XData',plotGenerations, 'YData',avgTimes);
            drawnow;
        end
        
        % Save Params if Time has Improved by More than 100sec or Another 10 Generations have Passed:
        if( pop(1).time > eliteTimes(end) + 100 || ~mod(gen,10) )
            flyer = pop(1);
            save('flyerParams.mat', 'flyer');
        end
        
        % Produce Next Generation:
        nElite = ceil(N/15); % Number of Elite Members that Survive into Next Generation (must be >1 for continuous improvement)
        nCrossSets = floor((N - nElite) / 4); % Number of Sets of Children Bred from Successful Parents
        nMutants = N - nElite - 4*nCrossSets; % Number of Children Mutated from Least Successful Members with High Probability
        
        % Elites:
        for i=1:nElite
            nextGen(i) = pop(i);
        end
        
        % Crossover Sets:
        for i=0:(nCrossSets-1)
            idx0 = nElite + 4*i; % Starting index
            a = 0.2 + 0.25*rand(); % Crossover ratio. Note: at 0.5, C1 and C2 will be identical
            m = 0.1 + (0.24-0.1) * (i+1) / nCrossSets; % Cumulative Individual Mutation Probability
            nextGen(idx0 + 1) = mutate(crossover(pop(2*i+1), pop(2*i+2), a), m);
            nextGen(idx0 + 2) = mutate(crossover(pop(2*i+2), pop(2*i+1), a), m);
            nextGen(idx0 + 3) = mutate(crossover(pop(2*i+1), pop(2*i+2), a/2), m);
            nextGen(idx0 + 4) = mutate(crossover(pop(2*i+2), pop(2*i+1), a/2), m);
        end
        
        % Mutants:
        for i=1:nMutants
            nextGen(N-nMutants+i) = mutate(pop(2*nCrossSets+i), 1); % Mutate most successful flyers that weren't successful enough to breed.
        end
        
        pop = nextGen;
        gen = gen + 1;
    end
    
    % Save Results:
    flyer = pop(1);
    save('flyerParams.mat', 'flyer');
    
    %% Genetic Helper Functions:
    % Crossover with a given ratio of "alleles" taken from parent 1:
    function child = crossover(parent1, parent2, ratio)
        for ii = 1:3
            ww{:,:,ii} = parent1.W{:,:,ii} * ratio + parent2.W{:,:,ii} * (1-ratio);
            bb{:,ii} = parent1.b{:,ii} * ratio + parent2.b{:,ii} * (1-ratio);
        end
        child = Flyer(ww,bb);
    end

    % Create a Mutated Version of the parent with a Total Mutation Probability of Ptot: 
    function child = mutate(parent, Ptot)
        Pgauss = 0.5 * Ptot; % Probability of gaussian mutation
        Pmix = 0.25 * Ptot; % Probability of shuffling weights within a range of rows
        Prev = 0.15 * Ptot; % Probability of reversing prder of a range of rows
        Pswap = 0.1 * Ptot; % Probability of two rows being swapped
        
        function out = swap(in)
            rangeStart = randi(size(in,1), 1);
            rangeLen = randi(size(in,1)-rangeStart+1, 1);
            out = in;
            out(rangeStart,:) = in(rangeStart+rangeLen-1,:);
            out(rangeStart+rangeLen-1,:) = in(rangeStart,:);
        end
        function out = rev(in)
            rangeStart = randi(size(in,1), 1);
            rangeLen = randi(size(in,1)-rangeStart+1, 1);
            out = in;
            out(rangeStart:rangeStart+rangeLen-1,:) = flip(out(rangeStart:rangeStart+rangeLen-1,:),1);
        end
        function out = mix(in)
            rangeStart = randi(size(in,1), 1);
            rangeLen = randi(size(in,1)-rangeStart+1, 1);
            out = in;
            tmp = out(rangeStart:rangeStart+rangeLen-1,:);
            out(rangeStart:rangeStart+rangeLen-1,:) = reshape(tmp(randperm(numel(tmp))), size(tmp));
        end
        function out = gauss(in)
            % Replace all values within random range of values with values
            % randomly chosen from normal distribution of acceptable
            % weights.
            ub = 75; % (5-sigma) Upper bound on weights
            mu = 1; % Mean Value for distribution of possible weights
            sigma = (ub-mu) / 5; % Std.Dev of distribution of possible weights
            out = in;
            rangeStart = randi(numel(out), 1);
            rangeLen = randi(numel(out)-rangeStart+1, 1);
            out(rangeStart:rangeStart+rangeLen-1) = normrnd(mu,sigma, 1,rangeLen);
        end
        for ii = 1:3
            ww{:,:,ii} = parent.W{:,:,ii};
            bb{:,ii} = parent.b{:,ii};
            if rand() < Pswap/size(parent.W,3)
                ww{ii} = swap(ww{ii});
                bb{ii} = swap(bb{ii});
            end
            if rand() < Prev/size(parent.W,3)
                ww{ii} = rev(ww{ii});
                bb{ii} = rev(bb{ii});
            end
            if rand() < Pmix/size(parent.W,3)
                ww{ii} = mix(ww{ii});
                bb{ii} = mix(bb{ii});
            end
            if rand() < Pgauss/size(parent.W,3)
                ww{ii} = gauss(ww{ii});
                bb{ii} = gauss(bb{ii});
            end
        end
        
        child = Flyer(ww,bb);
    end
end





























%% DO NOT MODIFY


function SYS = GenerateLevel(SYS)

rng(SYS.level);

SYS.yLims = [-50 50];
SYS.xLims = [-75 75];
SYS.Npoints = 10000;

x =SYS.xLims(1):1:SYS.xLims(2);

t = linspace(0,100*SYS.Npoints/10000,SYS.Npoints);
y = zeros(1,SYS.Npoints);
w = 50*ones(1,SYS.Npoints);

 for i = 1:50
     y = y+ 30 *(rand()-.5)/i^.5* sin(i/10*t.*(1+t/1000));
     %w = w+ abs((10) *(rand())/i^.5* sin(i/10*t));
 end 
 w = abs(w);
 w = w.*exp(-t/10);
 w(1:75) = linspace(50,0,75) + w(1:75);
 w(9000:10000) = 0;

 y(1:75) = 0;
 y(76:76+100-1) = linspace(0, y(76+100-1),100);
 
 SYS.y1 = y+w/2;
 SYS.y2 = y - w/2;
 SYS.x = x;
 
end 
 
 
 

 
 function AnimateShip(SYS)
 tframe = SYS.tframe;
 
 xLims = SYS.xLims;
 yLims = SYS.yLims;
 x = SYS.x;
 y1 = SYS.y1;
 y2 = SYS.y2;
 ys = SYS.ys;

hfig = figure('Visible', 'off');
hax = axis;
 axis equal
 xlim(xLims - [0 2])
 ylim(yLims)
 
  hold on

h = fill([x(1), x, x(2)], [yLims(2),y1(1:length(x)) yLims(2)], 'k',...
    [x(1), x, x(2)], [yLims(1),y2(1:length(x)) yLims(1)], 'k');

xShip = [0 -7 -7];
yShip = [0 -3 3];
hs = patch(xShip,yShip,'rx');

hsense = plot([5 5], [y1(80) y2(80)], 'g.', 'MarkerSize', 20);
htail = plot([-74:0], nan(1,75), 'r');
htitle = title('running');


ht = text(-70, 40, '', 'Color', 'y', 'BackgroundColor', 'b');


hold off

 
for j = 1:10000 - 75

% update wall positions
h(1).YData = [yLims(2),y1(j:j+length(x)-3) yLims(2)];
h(2).YData = [yLims(1),y2(j:j+length(x)-3) yLims(1)];

hsense.YData = [y1(80+j) y2(80+j)];

%update ship position, taking into acount rotation
dy = ys(j+ 75) - ys(j+75-1);
theta = atan2(dy, 1);
XShip2 = cos(theta)*xShip -  sin(theta)*yShip;
YShip2 = sin(theta)*xShip +  cos(theta)*yShip;

hs.YData = ys(j)+YShip2;
hs.XData = XShip2;

%update tail
n = min(j, 75);
htail.YData(end-n+1:end) = ys(j-n+1:j);


% pause frame base on desired framerate
pause(tframe)

if SYS.InTrack(j)
    htitle.String = 'Out of track - failed!';
end 

ht.String = {['METRICS     '];...
            ['F = ', num2str(SYS.F(j),3)];...
               ['y = ', num2str(SYS.ys(j),3)];...
               ['v = ', num2str(SYS.vs(j),3)];...
               ['t = ', num2str(j)];...
               ['t_{fail} = ', num2str(SYS.Iimpact)]};

if j==SYS.Iimpact
    pause
    htitle.String = 'Impact!';
    disp('Press any key to countinue animating')
end         
           
hfig.Visible= 'on';

end 
 
 end 
 
function SYS = CalculateShipPath(SYS)


y1 = SYS.y1;
y2 = SYS.y2;

F = 0;
vyShip = 0;
yShip = (y1(75) + y2(75))/2;

SYS.ys = nan(0,10000);
SYS.F = nan(0,10000);
SYS.vs = nan(0,10000);

for i = 1:10000 - 75 - 5
    
   yWall1 = y1(i+75:i+75+5);
   yWall2 = y2(i+75:i+75+5);
   
   
    F = ShipController(yWall1, yWall2, yShip, vyShip);
    
    % SET MAX FORCE TO +-2
    if F > 2
        F = 2;
    elseif F<-2
        F = -2;  
    end 
    
    [yShip, vyShip] = ShipDynamics(yShip, vyShip, F);
    
    SYS.ys(i) = yShip;
    SYS.F (i) = F;
    SYS.vs(i) = vyShip;
end 
    SYS = EvaluateImpact(SYS);
    %disp(['The ship survived ', num2str(SYS.Iimpact), ' seconds']);

end 


function SYS = EvaluateImpact(SYS)

n= length(SYS.ys)-1;
I = (SYS.ys >= SYS.y1(75:75+n)) | (SYS.ys <= SYS.y2(75:75+n));
Iimpact = find(I, 1);
SYS.Iimpact = Iimpact;
SYS.InTrack = I;
end 


function [yShip, vyShip] = ShipDynamics(yShip, vyShip, F)

dt = 1;
m = 100;

yShip = yShip+vyShip*dt + .5*F/m*dt^2;
vyShip = vyShip+F/m*dt;


end 



