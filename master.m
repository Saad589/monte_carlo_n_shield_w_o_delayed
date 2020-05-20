% A simple Monte Carlo code for neutron shielding w/o considering the
% contribution of delayed neutrons
% Saad Islam, DAK 
% 27-Apr-2020

% dev note: velocity and energy are NOT related 

%%------------------------------Preamble---------------------------------%%
a = 1; % inner diameter 
b = 1.5; % outer diameter

% v = 1; % initial velocity irrespective of energy
tau = 0.2; % mean free time for velocity, v = 1
f = 0.95; % inelasticity parameter

A = 12; % A = atomic mass / neutron mass
pa = 0.05; % absorption probability

energy_i_t = 4.80e6;
% lamarsh
% the energy threshold for inelastic scattering for C-12
% at energies above threshold σi is roughly equal to σs

n = 100; % no. of iterations

%%------------------------------Inits------------------------------------%%
figure;
hold on;

circle(0,0,1.0);
circle(0,0,1.5);

axis([-2 2 -2 2]);
pbaspect([1 1 1]);

fid = fopen('history.csv','w');
fprintf(fid,'n_ind,loc,spd,dt,eng,remark\n');

%%----------------------------Event Loop---------------------------------%%
for i = 1:n
    energy = get_energy();
    r = rand();
    v = 1; % each new n is produced with a velocity of 1
    
    [rx,ry,r] = get_component(r);
    [vx,vy,v] = get_component(v);
    
    remark = 'alive';
    fprintf(fid,'%d,%.5f,%.2f,0,%.2f,%s\n',i,r,v,energy,remark);
    scatter(rx,ry,'r*');
    quiver(rx,ry,vx,vy,'b');
    
    rv = get_dot_product(rx,ry,vx,vy);
    t = (sqrt((a^2-r^2)*(v^2) + rv^2) - rv) / v^2; % time to boundary
    rx = rx + t*vx;
    ry = ry + t*vy;
    r = sqrt(rx^2 + ry^2); % boundary
    
    fprintf(fid,'%d,%.5f,%.2f,%.2f,%.2f,%s\n',i,r,v,t,energy,remark);
    scatter(rx,ry,'b*');
%     quiver(rx,ry,vx,vy,'b');
    % after time t, n is at boundary. no interaction yet. v is unchanged.

    drawnow;
%     pause(1);

    captured = 0;
    escaped = 0;
    
    while ~captured && ~escaped
%  
%         [vx,vy,v] = get_v_v2(v);
%         quiver(rx,ry,vx,vy,'b');        
        t = -tau*log(rand()); % after this there shall be an interaction
        rx = rx + t*vx;
        ry = ry + t*vy;
        r = sqrt(rx^2 + ry^2); % location where interaction takes place

        if energy <= 10000000 % far too large than the max energy
            % unfortunately this below portion will never run because
            % there are no neutrons in excess of 2MeV and the threshold
            % is 4.8Mev
            if energy > energy_i_t
                kk = randi([1,2],1,1);
                if kk == 1
                    % inelastic scattering event
                    energy = energy * rand();
                    [vx,vy,v] = get_component(v,f);
                    remark = 'inelastic-scatter';
                elseif kk == 2                
                    energy = energy * ( (1-A)^2 / (1+A)^2 );
                    v = 0.5 * v;
                    [vx,vy,v] = get_component(v);
                    remark = 'elastic-scatter';
                end
            else
                energy = energy * ( (1-A)^2 / (1+A)^2 );
                v = 0.5 * v;
                [vx,vy,v] = get_component(v);
                remark = 'elastic-scatter';
            end
        else
            disp('impossible energy');
            energy = energy * rand(); % dummy
        end

        if r > b 
            escaped = 1;
            remark = 'escaped';
        elseif r < a
            escaped = 1;
            remark = 'back-scatter';
        elseif energy < 1 || rand() < pa
            captured = 1;
            remark = 'captured';
        end
        
        fprintf(fid,'%d,%.5f,%.2f,%.2f,%.2f,%s\n',i,r,v,t,energy,remark);
        scatter(rx,ry,'b*');
        quiver(rx,ry,vx,vy,'b');
        
        drawnow; 
%         pause(1);
    end
end

% saveas(gcf,'img.png');

closeresult = fclose(fid);
if closeresult == 0
    disp('File close successful');
else
    error('File close not successful');
end

%%-------------------------In-script Functions---------------------------%%
function circle(x,y,r)
% x and y are the coordinates of the center of the circle
% r is the radius of the circle
ang=0:0.01:2*pi; 
xp=r*cos(ang);
yp=r*sin(ang);
plot(x+xp,y+yp,'k');
end