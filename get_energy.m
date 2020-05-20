function out_energy = get_energy()
% tallying the PRNG to avoid clumping
% ranges are not of equal width
% this is sort of like a pdf derived form normal dist
    det = randi([1,4]); % number of tiles
    if det == 1
        out_energy = rand(); % 25% chance (0-1)
    elseif det == 2
        out_energy = 1 + (10000-1)*rand(); % 25% chance (1-1e4)
    elseif det == 3
        out_energy = 10000 + (2000000-10000)*rand(); % 25% chance (1e4-2e6)
    elseif det == 4
        % simulating the rand() function of C
        % in C rand() outputs 1 to RAND_MAX
        % RAND_MAX is usually 32767
        % so, 2MeV + paddind
        out_energy = 2000000 + mod(randi([1,32768]),100); % 25% chance (2e6-2000327)
    end
end

% dev note: needs work done. draw from a pdf using importance sampling 