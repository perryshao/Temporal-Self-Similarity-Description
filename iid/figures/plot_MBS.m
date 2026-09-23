n = size(MBS.data,2);
m = size(MBS.data{1,1},2);
% set(gcf,'position',[50,50,1600,1200]);
view(-37.5,30);
if m < 3
    for i = 1:n
        X = [MBS.data{1,i}(1,1);MBS.data{1,i}(end,1)];
        Y = [MBS.data{1,i}(1,2);MBS.data{1,i}(end,2)];

%         axis equal;
        plot(MBS.data{1,i}(:,1),MBS.data{1,i}(:,2),...
                       '.r','MarkerSize',20);hold on;
%         axis equal;
        plot(X,Y,'.-b');hold on;grid on;
    end
else
    for i = 1:n
        X = [MBS.data{1,i}(1,1);MBS.data{1,i}(end,1)];
        Y = [MBS.data{1,i}(1,2);MBS.data{1,i}(end,2)];
        Z = [MBS.data{1,i}(1,3);MBS.data{1,i}(end,3)];
%         axis equal;
        pause(0.5)
        plot3(MBS.data{1,i}(:,1),MBS.data{1,i}(:,2),MBS.data{1,i}(:,3),...
                         '.r','MarkerSize',15);hold on;
%         axis equal;
        plot3(X,Y,Z,'.-b');hold on;grid on;
    end
end
axis equal;
