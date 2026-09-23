function  inter_curve=interpolation(curve,length,flag)

% inter_curve=[];
%% define the numbers of points to be interpolated
samples=size(curve,1);
samples=length-samples;

%% interpolate the samples in original trajectory
CS = cat(1,0,cumsum(sqrt(sum(diff(curve,[],1).^2,2))));
inter_curve = interp1(CS, curve, unique([CS(:)' linspace(0,CS(end),samples)]),'spline');
%% plot the interploation results trajectory for comparison
if flag==1
figure, hold on;
plot3(curve(:,1),curve(:,2),curve(:,3),'.b-');
plot3(inter_curve(:,1),inter_curve(:,2),inter_curve(:,3),'.r-');grid on;
axis image, view(3), legend({'Original','Interp. cubic'});
end