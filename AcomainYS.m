%% I. ��ջ�������
clear all
clc

%% II. ��������
citys = [716180.123,3530667.308,70.011;
716180.123,3530668.20000214,60.412;
716180.123,3530668.308,50.819;
716180.123,3530669.20000214,43.360;
716180.123,3530670.308,40.849;
716180.123,3530671.20000214,64.954;
716180.123,3530672.308,73.021;
716177.123,3530694.20000214,64.747;
716180.123,3530718.225,73.021;
716180.123,3530719.308,65.015;
716180.123,3530720.654,55.729];
%citys = [2 5 91;3 6 85;4 7 55;5 8 45;7 9 25;9 10 70;...
 %   11 11 92; 20 12 95;29 13 94;31 14 71;35 15 50;0 0 0];

V_LAND =10; %���٣����ǰΪ���˻��趨���ٶ�
V_WIND =5; %���ٴ�С
POWER = 166;
beta_wind = 5*pi/4;%���ٵļн�

%% III. ������м��໥����
n = size(citys,1);
D = zeros(n,n);
for i = 1:n
    for j = 1:n
        if i ~= j
            time_direct = sqrt(sum((citys(i,:) - citys(j,:)).^2))/V_LAND;
        		D(i,j) = calculate_V(citys(j,3),citys(j,2),citys(j,1),citys(i,3),citys(i,2), citys(i,1))*POWER*time_direct ;
                D(j,i) = calculate_V(citys(i,3),citys(i,2), citys(i,1), citys(j,3),citys(j,2),citys(j,1))*POWER*time_direct ;
        else
            D(i,j) = 1e-4;      
        end
    end    
end

%% IV. ��ʼ������
m = 100;                             % ��������
alpha = 1;                           % ��Ϣ����Ҫ�̶�����
beta = 5;                            % ����������Ҫ�̶�����
rho = 0.2;                           % ��Ϣ�ػӷ�����
Q = 10;                              % ��ϵ��
Eta = 1./D;                          % ��������
Tau = ones(n,n);                     % ��Ϣ�ؾ���
Table = zeros(m,n);                  % ·����¼��
iter = 1;                            % ����������ֵ
iter_max = 500;                      % ���������� 
Route_best = zeros(iter_max,n);      % �������·��       
Length_best = zeros(iter_max,1);     % �������·���ĳ���  
Length_ave = zeros(iter_max,1);      % ����·����ƽ������
Limit_iter = 0;                      % ��������ʱ��������

%% V. ����Ѱ�����·��
while iter <= iter_max
     % ��������������ϵ�������
      start = zeros(m,1);
      for i = 1:m
          temp = randperm(n);
          start(i) = temp(1);%50�����ϵĳ�������
          %start(i) = 12;
      end
      Table(:,1) = start; 
      citys_index = 1:n;
      % �������·��ѡ��
      for i = 1:m
          % �������·��ѡ��
         for j = 2:n
             tabu = Table(i,1:(j - 1));           % �ѷ��ʵĳ��м���(���ɱ�)
             allow_index = ~ismember(citys_index,tabu);%ismember����һ��������Ԫ���Ƿ�Ϊ�ڶ��������е�ֵ
             allow = citys_index(allow_index);  % �����ʵĳ��м���
             P = allow;
             % ������м�ת�Ƹ���
             for k = 1:length(allow)
                 P(k) = (Tau(tabu(end),allow(k))^alpha) * (Eta(tabu(end),allow(k))^beta);
             end
             P = P/sum(P);
             % ���̶ķ�ѡ����һ�����ʳ���
             Pc = cumsum(P);     
            target_index = find(Pc >= rand); 
            target = allow(target_index(1));
            Table(i,j) = target;
         end
      end
      % ����������ϵ�·������
      Length = zeros(m,1);
      for i = 1:m
          Route = Table(i,:);
          for j = 1:(n - 1)
              Length(i) = Length(i) + D(Route(j),Route(j + 1));
          end
          Length(i) = Length(i) + D(Route(n),Route(1));
      end
      % �������·�����뼰ƽ������
      if iter == 1
          [min_Length,min_index] = min(Length);
          Length_best(iter) = min_Length;  
          Length_ave(iter) = mean(Length);
          Route_best(iter,:) = Table(min_index,:);
          Limit_iter = 1;
      else
          [min_Length,min_index] = min(Length);
          Length_best(iter) = min(Length_best(iter - 1),min_Length);
          Length_ave(iter) = mean(Length);
          if Length_best(iter) == min_Length
              Route_best(iter,:) = Table(min_index,:);
              Limit_iter = iter;
          else
              Route_best(iter,:) = Route_best((iter-1),:);
          end
      end
      % ������Ϣ��
      Delta_Tau = zeros(n,n);
      % ������ϼ���
      for i = 1:m
          % ������м���
          for j = 1:(n - 1)
              Delta_Tau(Table(i,j),Table(i,j+1)) = Delta_Tau(Table(i,j),Table(i,j+1)) + Q/Length(i);
          end
          Delta_Tau(Table(i,n),Table(i,1)) = Delta_Tau(Table(i,n),Table(i,1)) + Q/Length(i);
      end
      Tau = (1-rho) * Tau + Delta_Tau;
    % ����������1�����·����¼��
    %Rlength(iter) = min_Length;
    iter = iter + 1;
    Table = zeros(m,n);
end

%% VI. �����ʾ
[Shortest_Length,index] = min(Length_best);
Shortest_Route = Route_best(index,:);
disp(['��̾���:' num2str(Shortest_Length)]);
disp(['���·��:' num2str([Shortest_Route Shortest_Route(1)])]);

%% VII. ��ͼ
figure(1)
plot3([citys(Shortest_Route,1);citys(Shortest_Route(1),1)],...
     [citys(Shortest_Route,2);citys(Shortest_Route(1),2)],...
     [citys(Shortest_Route,3);citys(Shortest_Route(1),3),],'o-');
 
grid on
for i = 1:size(citys,1)
    text(citys(i,1),citys(i,2),citys(i,3),['   ' num2str(i)]);
end
text(citys(Shortest_Route(1),1),citys(Shortest_Route(1),2),citys(Shortest_Route(1),3),'       ���');
text(citys(Shortest_Route(end),1),citys(Shortest_Route(end),2),citys(Shortest_Route(end),3),'       �յ�');
set(gca, 'xtick', 0 : 5 : 40);
set(gca, 'ytick',0 : 2 : 16, 'ydir','reverse' );
xlabel('����λ�ú�����')
ylabel('����λ��������')
zlabel('����λ�ø߳�����')
title(['��Ⱥ�㷨�Ż�·��(��̾���:' num2str(Shortest_Length) ')'])
figure(2)
plot(1:iter_max,Length_best,'b',1:iter_max,Length_ave,'r:')
legend('��̾���','ƽ������')
xlabel('��������')
ylabel('����')
title('������̾�����ƽ������Ա�')
figure(3)
plot(1:iter_max,Length_best,'b')
xlabel('��������')
ylabel('Ŀ�꺯��ֵ')
title('��Ӧ�Ƚ�������')