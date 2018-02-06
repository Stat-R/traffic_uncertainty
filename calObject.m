function [ objVal,AACE,noabs_AACE,Sharp] = calObject( preInterval,target,m1,m2,w1,w2,conInterval)
% preInterval is the prediction interval for each observation
% target is the real value
% conInterval 99%, 95%, 90%
% flag 0 means all the lower bound is less than the upper bound, otherwise
% it will be 1, recalculate the output weights in the extreme learning
% network
% AACE is A score
% Sharp is Sharpness score

% m1, max value
% m2, min value
% m1, m2 are used to normalize the data

flag=0;
% one column is one observation
% normalize first
preInterval=(preInterval-m2)/(m1-m2);
target=(target-m2)/(m1-m2);

[n1,n2]=size(preInterval);
cor=0; %  correct predictions
for i=1:1:n1
    if target(i)>=preInterval(i,1) && target(i)<=preInterval(i,2)
        cor=cor+1;
    end
end

% reliability
re=cor/n1;
% average coverage error
AACE=abs(re-conInterval);
noabs_AACE=re-conInterval;
% sharpness
% conInterval=0; % remember to comment back;
S=[];
for i=1:1:n1
    if preInterval(i,1)<0
         preInterval(i,1)=0;
         flag = 2;
    end
    if preInterval(i,1)<=preInterval(i,2)  %% lower bound should be greater than or equal to 0
        v=preInterval(i,2)-preInterval(i,1);
        if target(i)<preInterval(i,1)
%             s=-2*(1-conInterval)*v-4*(preInterval(i,1)-target(i));
%            v is usually around 300 vehicles, so in order to make
%            comparable with reliability, w1 is set as 0.01,
%            0.01*(1-0.95)*300=0.15
             s=-w1*(1-conInterval)*v-w2*(preInterval(i,1)-target(i));
        elseif target(i)>preInterval(i,2)
%             s=-2*(1-conInterval)*v-4*(target(i)-preInterval(i,2));
            s=-w1*(1-conInterval)*v-w2*(target(i)-preInterval(i,2));%?????????????????????
        else
            s=-w1*(1-conInterval)*v;
        end
%         S=[S;abs(s)];
        v1=(preInterval(i,2)+preInterval(i,1))/2;
       
        S=[S;abs(s)];
    else
        S=[S;0]; % any number
        flag=1;
        break;
    end
end
% normalize S into [0,1];
% normSharp=(S(:,1)-ms)./(mb-ms);
% A=mean(normSharp);
% A=S(:,1);

preInterval=preInterval*(m1-m2)+m2;% reverse the normalization
target=target*(m1-m2)+m2;

Sharp=mean(S(:,1));% jinliang suoduan juli
% Sharp=0;
objVal=AACE+Sharp; % objective error is to minize this
end

