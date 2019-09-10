function PS2()
    % Part 1:
    z1 = 1 + 1j; z2 = -1 - 2j;
    part1(z1);
    part1(z2);
    part1(z1+z2);
    part1(z1*z2);
    part1(z1/z2);
    part1(z1*conj(z1));
    
    % Part 3:
    figure();
    plotz( @(w) w.^2 + 2j./w );
    
    figure();
    plotz( @(w) 1j.*w./(1 + 1j.*w) );
    
    % Part 5:
    figure();
    plotz( @(w)  (3+w*1j) .* (4+w*1j) ./ (1+w*1j) ./ (10+w*1j) ./ (2+w*1j) );
    title({'24451 - PS2 - Part 5, $z = \frac{(3+wj)(4+wj)}{(1+wj)(10+wj)(2+wj)}$'}, 'Interpreter', 'latex');
    saveas(gcf, 'PS2_5.png', 'png');
    
    % Part 6:
    w6 = linspace(-1e9, 1e9, 1e7);
    z6 = (3+w6*1j) .* (4+w6*1j) ./ (1+w6*1j) ./ (10+w6*1j) ./ (2+w6*1j);
    
    figure();
    subplot(2,1,1);
    semilogx(w6, abs(z6));
    title({'$z=\frac{(3+wj)(4+wj)}{(1+wj)(10+wj)(2+wj)}$'}, 'Interpreter', 'latex');
    xlabel('$w$', 'Interpreter', 'latex');
    ylabel('$M(z)$', 'Interpreter', 'latex');
    subplot(2,1,2);
    title({'$z=\frac{(3+wj)(4+wj)}{(1+wj)(10+wj)(2+wj)}$'}, 'Interpreter', 'latex');
    semilogx(w6, phase(z6));
    xlabel('$w$', 'Interpreter', 'latex');
    ylabel('$\varphi(z)$', 'Interpreter', 'latex');
    
    saveas(gcf, 'PS2_6.png', 'png');
end

function part1(z)
    disp(abs(z) + ", " + phase(z)*180/pi + ", " + real(z) + ", " + imag(z));
end

function plotz(z)
    persistent ww;
    if isempty(ww)
        ww = linspace(-1e9, 1e9, 1e7);
    end
    plot(real(z(ww)),imag(z(ww)));
    xlabel('$Re(z)$', 'Interpreter', 'latex');
    ylabel('$Im(z)$', 'Interpreter', 'latex');
end


