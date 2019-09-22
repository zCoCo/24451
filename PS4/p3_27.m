function p3_27()
    % Verify Results:
    K = 109; a = 67; % Compensator parameters
    sys = tf(100*K, [1,(a+25),(25*a+100*K)]);
    [y,t] = step(sys);
    yinf = y(end);
    
    figure();
    hold on
        plot(t,y);
        hline(yinf, '', 'left');
    hold off
    xlabel('Time [s]', 'Interpreter', 'latex');
    ylabel('Amplitude', 'Interpreter', 'latex');
    title({'Unit Step Response'}, 'Interpreter', 'latex');
    
    
    % Plot Constraints:
    z = (a + 25)/(10*(4*K + a)^(1/2));
    wn = 5*(4*K + a)^(1/2);
    syms t
    envelope = @(x) yinf + exp(-z*wn*x)/sqrt(1-z^2);
    ylim([0 1.35]);
    hline(1.25*yinf, "$\quad$Maximum Overshoot of 25\%", 'left', 'bottom');
    vline(solve(envelope(t)==1.005*yinf,t), "1\% Settling time$\;$");
    saveas(gcf, 'p3_27.png', 'png');
end

 % Draws a grey verical dashed line at the given X-axis value on the
% current plot, with a label of the given text at the bottom (or
% top).
% side: 'left','right','center','auto'
% valign: 'top','bottom'
function vline(x, txt, side, valign, color)
    if nargin < 3
        side = 'auto';
    end
    if nargin < 4
        valign = 'bottom';
    end
    if nargin < 5
        color = [0.5 0.4 0.4]; % grey
    end

    if strcmp(side, 'auto')
        if x > mean(xlim)
            side = 'right';
        else
            side = 'left';
        end
    end

    hold on
        plot([x x], ylim, ':', 'Color', color);
        size = ylim;
        if strcmp(valign, 'bottom')
            fact = 0.05;
        else
            fact = 0.95;
        end
        text(x, fact*diff(size) + size(1), char(txt), 'Color', color, 'HorizontalAlignment', side, 'Interpreter', 'latex');
    hold off
end
% Draws a grey horizontal dashed line at the given Y-axis value on 
% the current plot, with a label of the given text at the left.
% pos: 'left','center','right'
% valign: 'top','middle','bottom','cap','baseline'
function hline(y, txt, pos, valign, color)
    if nargin < 3
        hfact = 1; % Horizontal Positioning Factor
    else
        hfact = (find(pos==["left" "center" "right"],1) - 1) / 2;
        if isempty(hfact)
            hfact = 1;
        end
    end
    if nargin < 4
        if y > mean(ylim)
            valign = 'top';
        else
            valign = 'bottom';
        end
    end
    if nargin < 5
        color = [0.5 0.4 0.4]; % grey
    end

    hold on
        plot(xlim, [y y], ':', 'Color', color);
        size = xlim;
        text(hfact*diff(size) + size(1), y, char(txt), 'Color', color, 'HorizontalAlignment', pos, 'VerticalAlignment', valign, 'Interpreter', 'latex');
    hold off
end