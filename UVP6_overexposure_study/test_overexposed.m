%test for functions in overexposed_pix_percent file
function tests = test_overexposed
    % build tests
    tests = functiontests(localfunctions);
end

function test_get_lines_indices(testCase)
    array_size = 1;
    lines_interval = 1;
    i_lines = get_lines_indices(array_size, lines_interval);
    assert(i_lines == 1);
end
    
    
function setupOnce(testCase)  % do not change function name
% set a new path, for example
end

function teardownOnce(testCase)  % do not change function name
% change back to original path, for example
end