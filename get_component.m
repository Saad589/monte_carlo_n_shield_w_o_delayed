function [varargout] = get_component(varargin)

% 
c = 1;
m = 1; 

%
if nargin == 1
    c = varargin{1};
elseif nargin == 2
    c = varargin{1};
    m = varargin{2};
end

%
c_theta = 2 * pi * rand();
cx = m * c * cos(c_theta);
cy = m * c * sin(c_theta);
c_out = sqrt(cx^2 + cy^2);

%
if nargout >= 2    
    varargout{1} = cx;
    varargout{2} = cy;
    varargout{3} = c_out;    
else
    error('Error in output arguments')
end