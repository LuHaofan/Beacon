sub='z';
load(['worksp/',sub,num2str(1)],'gnd_true_list');
all_list = [];
for i=1:8
    if i == 4
        continue;
    end
    load(['worksp/',sub,num2str(i)],'gnd_soft_list');
    gnd_soft_list = gnd_soft_list(1:25,:);
    gnd_recursive = repmat(gnd_true_list,5,1);
    gnd_temp = gnd_recursive(1:size(gnd_soft_list,1),:);
    temp_list = [gnd_soft_list,gnd_temp];
    err_list = vecnorm((temp_list(:,1:2)-temp_list(:,3:4))');
    all_list = [all_list;err_list];
end
errorbar(mean(all_list),std(all_list));