function [ h ] = circles(x,y,r,varargin)


assert(isnumeric(x),'Input x must be numeric.') 
assert(isnumeric(y),'Input y must be numeric.') 
assert(isnumeric(r),'Input r must be numeric.') 

if ~isscalar(x) && ~isscalar(y)
    assert(numel(x)==numel(y),'If neither x nor y is a scalar, their dimensions must match.')
end
if ~isscalar(x) && ~isscalar(r)
    assert(numel(x)==numel(r),'If neither x nor r is a scalar, their dimensions must match.')
end
if ~isscalar(r) && ~isscalar(y)
    assert(numel(r)==numel(y),'If neither y nor r is a scalar, their dimensions must match.')
end


tmp = strcmpi(varargin,'points')|strcmpi(varargin,'NOP')|strcmpi(varargin,'corners')|...
    strncmpi(varargin,'vert',4); 
if any(tmp)
    NOP = varargin{find(tmp)+1}; 
    tmp(find(tmp)+1)=1; 
    varargin = varargin(~tmp); 
else
    NOP = 1000; 
end


tmp = strncmpi(varargin,'rot',3);
if any(tmp)
    rotation = varargin{find(tmp)+1}; 
    assert(isnumeric(rotation)==1,'Rotation must be numeric.')
    rotation = rotation*pi/180; 
    tmp(find(tmp)+1)=1; 
    varargin = varargin(~tmp); 
else
    rotation = 0; 
end


tmp = strcmpi(varargin,'color');
if any(tmp)
    varargin{tmp} = 'facecolor'; 
end


x = x(:); 
y = y(:);
r = r(:); 
rotation = rotation(:); 

numcircles = max([length(x) length(y) length(r) length(rotation)]); 


if length(x)<numcircles
    x(1:numcircles) = x; 
end

if length(y)<numcircles
    y(1:numcircles) = y; 
end

if length(r)<numcircles
    r(1:numcircles) = r; 
end

if length(rotation)<numcircles
    rotation(1:numcircles) = rotation; 
end


t = 2*pi/NOP*(1:NOP); 


holdState = ishold; 
hold on; 

h = NaN(size(x)); 

 
for n = 1:numcircles
    h(n) = fill(x(n)+r(n).*cos(t+rotation(n)), y(n)+r(n).*sin(t+rotation(n)),'',varargin{:});
end


if ~holdState
    hold off
end


if nargout==0 
    clear h 
end

end