function ticksVector = getTicks(limit)
% time ticks
ticksVector(1) = floor(limit(1));
ticksVector(2) = floor(limit(1) + (limit(2) - limit(1))/5);
ticksVector(3) = floor(limit(1) + 2*(limit(2) - limit(1))/5);
ticksVector(4) = floor(limit(1) + 3*(limit(2) - limit(1))/5);
ticksVector(5) = floor(limit(1) + 4*(limit(2) - limit(1))/5);
ticksVector(6) = floor(limit(2));