local nCurFrame = 0
local nFrameTime, nCurTime, getTime = 0, 0, sys.gettime

function frameNum()
    return nCurFrame
end

function curtime()
    return nCurTime
end

function deltatime()
    return nFrameTime
end

local nTimeStart

function frameBegin()
    nTimeStart = getTime()
end

function frameEnd()
    nFrameTime = getTime() - nTimeStart
    nCurTime = nCurTime + nFrameTime
    nCurFrame = nCurFrame + 1
end
