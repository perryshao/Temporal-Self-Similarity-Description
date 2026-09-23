function RankOne_Des = RankOneDecom_Feaures(traindata,joints_no,descrip_flag)
N = length(traindata);
RankOne_Des = cell(1,N);
m_num = length(joints_no);
for n = 1:N
    fprintf ('RankOne descriptor computing %d-%d\n',n,N);
    Msv = zeros(m_num,m_num,0);
    K=size(traindata{n},1);
    for i = 1:K
        Msv_temp = self_similarity(traindata{n}(i,:),m_num,descrip_flag);
        if any(isnan(Msv_temp))
            continue;
        else
            Msv(:,:,end+1) = Msv_temp;
        end
    end
    %**********************************************
    %--- data parameters
    I=size(Msv,1);                      % Dimensions  of the tensor
    J=size(Msv,2);
    K;
    R=1;                                % Rank of the tensor
    %***************************************************
    lsearch='elsr';     % line search, can be 'none', 'lsh', 'lsb', 'elsr' or 'elsc'
    comp='on';          % ='on' or ='off' to perform dimensionality reduction or not
    Tol1=1e-6;          % Tolerance of ALS
    MaxIt1=5000;        % Max number of iterations
    Tol2=1e-5;          % tolerance in refinement stage (after decompression if it was used)
    MaxIt2=500;         % Max number of iterations in refinement stage
    Ninit = 4;
    
    for ninit=1:Ninit
        
        % generate matrices to initialize (note that cp_init is included in cp3als file such that if A_init, B_init and
        % C_init are not given as input arguments, cp3als will generate starting points by himself)
        if ninit==1
            [A_init,B_init,C_init]=cp3_init(Msv,R,'dtld');     % do init by dtld (ESPRIT like)
        else
            [A_init,B_init,C_init]=cp3_init(Msv,R,'random');  % force random init (because the init by dtld was eventually done before)
        end
        %  COMPUTE THE DECOMPOSITION for this initialization
        [U1,U2,U3,phi,it1,it2,phi_vec]=cp3_alsls(Msv,R,lsearch,comp,Tol1,MaxIt1,Tol2,MaxIt2,Ninit,A_init,B_init,C_init);
    end
    RankOne_Des{1,n} = [U1' U2' U3'];
end
