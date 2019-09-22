function PS3_9()
    %% Init
    syms y(t) real
    syms t real
    syms s
    syms Y
    d = @(xx) diff(xx,t,1);
    dy = d(y)
    dy2 = d(d(y))
    
    %% Solve ODEs:
    disp('## TEXTBOOK PROBLEM 3.9.a ##');
        y0 = 1
        dy0 = 2
        eqn = dy2 + dy + 3*y - 0
    
        eqn2 = laplace(eqn, t, s)
        eqn3 = subs(eqn2, y(0), y0)
        eqn3 = subs(eqn3, 'D(y)(0)', dy0) % works in MATLAB 2017a may have to be replaced with str2sym('D(y)(0)') in subsequent versions
        eqn3 = subs(eqn3, laplace(y(t), t, s), Y) % This may change based on your version of Matlab

        eqn4 = solve(eqn3, Y)
        yy = ilaplace(eqn4, t)
        pretty(yy)
        yy = vpa(yy,4)
        
    disp('## TEXTBOOK PROBLEM 3.9.f ##');
        y0 = 1
        dy0 = -1
        eqn = dy2 + y - t
    
        eqn2 = laplace(eqn, t, s)
        eqn3 = subs(eqn2, y(0), y0)
        eqn3 = subs(eqn3, 'D(y)(0)', dy0) % works in MATLAB 2017a may have to be replaced with str2sym('D(y)(0)') in subsequent versions
        eqn3 = subs(eqn3, laplace(y(t), t, s), Y) % This may change based on your version of Matlab

        eqn4 = solve(eqn3, Y)
        yy = ilaplace(eqn4, t)
        pretty(yy)
        yy = vpa(yy,4)
end