function p3_28()
    tpp = 0.6;
    figure();
    hold on
        fill([-1 1 1 -1], [tpp tpp 1 1], 'b');
        fill([-1 1 1 -1], [-tpp -tpp -1 -1], 'b');
        plot([0 0],[-1 1], 'k');
        plot([-1 1],[0 0], 'k');
    hold off
    hline(-tpp+0.005, "\quad$\omega_d' \rightarrow t_p'$", 'left', 'bottom');
    hline(tpp-0.005, "$\quad\omega_d' \rightarrow t_p'$", 'left', 'top');
    title({"3.28 Acceptable poles in blue such that peak time $t_p < t_p'=0.6$"}, 'Interpreter', 'latex');
    xlabel('$\sigma$', 'Interpreter', 'latex');
    ylabel('$j\omega$', 'Interpreter', 'latex');
    saveas(gcf, 'p3_28.png', 'png');
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