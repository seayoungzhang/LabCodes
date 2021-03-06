clear;
load '../Data/EEG/EEG_X.mat';
load '../Data/EEG/EEG_Y.mat';

data = [];
for i = 1:size(X, 2)
    data = [data; X{i}];
end

data = mapstd(data')';
count = 0;
for i = 1:size(X, 2)
    train_data = [];
    train_label = [];
    head = 1;
    tail = 0;
    for j = 1:size(X, 2)
        tail = tail + size(X{j}, 1);
        if(j~=i)
            train_data = [train_data; data(head:tail, :)];
            train_label = [train_label; Y{j}];
        else
            test_data = data(head:tail, :);
            test_label = Y{i};
        end
        head = tail + 1;
    end
    model = templateSVM('KernelFunction', 'linear', 'GapTolerance', 1e-5, 'Standardize', false);
    %model = templateSVM('KernelFunction', 'polynomial', 'PolynomialOrder', 1);
    %model = templateSVM('KernelFunction', 'rbf');
    model = fitcecoc(train_data, train_label, 'Learners', model, 'Verbose', 0);
    acc = sum(predict(model, test_data) == test_label)/size(test_data, 1);
    fprintf('Acc: %f\n', acc);
    count = count + acc;
end
fprintf('Overall Acc: %f\n', count/15);
