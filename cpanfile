requires 'Moose';
requires 'Time::Duration';
requires 'Data::UUID';
requires 'File::Spec';
requires 'YAML';
requires 'perl', '5.010001';

on test => sub {
    requires 'Test::More', 0.88;
};
