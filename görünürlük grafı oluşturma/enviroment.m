function [ vertices ] = environment( )


    vertices = zeros(10,3);

    [x,y] = ginput(10);

    vertices(1,:) = [x(1) y(1) 0];
    vertices(2:5,:) = [x(2:5) y(2:5) ones(4,1)];
    vertices(6:9,:) = [x(6:9) y(6:9) (ones(4,1).*2)];
    vertices(10,:) = [x(10) y(10) 3];

    plot( x(1), y(1), 'bo' )
    hold on;
    plot([x(2:5); x(2)],[y(2:5); y(2)]);
    hold on;
    plot([x(6:9); x(6)],[y(6:9); y(6)]);
    hold on;
    plot(x(10),y(10), 'ro');

end