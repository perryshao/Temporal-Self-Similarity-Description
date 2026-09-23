%USAGE: drawskt(1,3,1,4,1,2) --- show actions 1,2,3 performed by subjects 1,2,3,4 with instances 1 and 2.
function drawskt(a1,a2,s1,s2,e1,e2)

J=[20     1     2     1     8    10     2     9    11     3     4     7     7     5     6    14    15    16    17;
    3     3     3     8    10    12     9    11    13     4     7     5     6    14    15    16    17    18    19];

B=[];
for a=a1:a2
    for s=s1:s2
        for e=e1:e2
            file=sprintf('MSRAction3DSkeletonReal2D/db/a%02i_s%02i_e%02i_skeleton.txt',a,s,e);
            fp=fopen(file);
            if (fp>0)
               A=fscanf(fp,'%f');
               B=[B; A];
               fclose(fp);
            end
        end
    end
end

l=size(B,1)/4;
B=reshape(B,4,l);
B=B';
B=reshape(B,20,l/20,4);

X=B(:,:,1);
Z=400-B(:,:,2);
Y=B(:,:,3)/4;
P=B(:,:,4);

for s=1:size(X,2)
    S=[X(:,s) Y(:,s) Z(:,s)];
  
    xlim = [0 800];
    ylim = [0 800];
    zlim = [0 800];
    set(gca, 'xlim', xlim, ...
             'ylim', ylim, ...
             'zlim', zlim);

    h=plot3(S(:,1),S(:,2),S(:,3),'r.');
    %rotate(h,[0 45], -180);
    set(gca,'DataAspectRatio',[1 1 1])
    axis([0 400 0 400 0 400])


    for j=1:19
        c1=J(1,j);
        c2=J(2,j);
        line([S(c1,1) S(c2,1)], [S(c1,2) S(c2,2)], [S(c1,3) S(c2,3)]);
    end
    
    pause(1/20)
end

figure(1);
S=[X(:,1) Y(:,1) Z(:,1)];
joints=plot3(S(:,1),S(:,2),S(:,3),'rs','markersize',10);

for j=1:19
    c1=J(1,j);
    c2=J(2,j);
    plot3([S(c1,1) S(c2,1)], [S(c1,2) S(c2,2)], [S(c1,3) S(c2,3)],'-rs','LineWidth',2);hold on;
end
S=[X(:,size(X,2)) Y(:,size(X,2)) Z(:,size(X,2))];
joints=plot3(S(:,1),S(:,2),S(:,3),'rs','markersize',10);hold on;
for j=1:19
    c1=J(1,j);
    c2=J(2,j);
    plot3([S(c1,1) S(c2,1)], [S(c1,2) S(c2,2)], [S(c1,3) S(c2,3)],'-bs','LineWidth',2);hold on;
end
S_begin=[X(:,1) Y(:,1) Z(:,1)];
S_end = [X(:,size(X,2)) Y(:,size(X,2)) Z(:,size(X,2))];

for j=1:size(X,2)-1
    S=[X(:,j) Y(:,j) Z(:,j)];S_next = [X(:,j+1) Y(:,j+1) Z(:,j+1)];
    for i = 1:20
        axis equal;plot3([S(i,1) S_next(i,1)],[S(i,2) S_next(i,2)],[S(i,3) S_next(i,3)],'-k','LineWidth',1);hold on;
    end
end

class_num = length(unique((trainGID)));
for i = 1:class_num
    trajectory = TRAJDB(2,(trainGID == i));
    class_len = length(trajectory);
    for j = 1:class_len
    plot3d(trajectory{1,j});
    xlabel('X','FontWeight','bold');ylabel('Y','FontWeight','bold');zlabel('Z','FontWeight','bold');
    saveas(gcf,strcat(num2str(i),'-',num2str(j)),'png')
    end
end
