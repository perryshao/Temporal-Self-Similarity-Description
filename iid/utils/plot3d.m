function plot3d(curve_3d,color)
if nargin == 1
    color = 'k';
end
if size(curve_3d,2) == 3,

    plot3(curve_3d(:,1),curve_3d(:,2),curve_3d(:,3),['.' color,'-']);
    axis equal;
    view(-45, 45);
    grid on;
elseif size(curve_3d,1) == 3,
     axis equal;
     plot3(curve_3d(1,:),curve_3d(2,:),curve_3d(3,:),['.' color,'-']);
     axis equal;
     view(-45, 45);
     grid on;
     return;
end
if size(curve_3d,2) == 2,
    plot(curve_3d(:,1),curve_3d(:,2),['.' color,'-']);
elseif size(curve_3d,1) == 2,
     plot(curve_3d(1,:),curve_3d(2,:),['.' color,'-']);
     return;
end