function isok = isvalid(obj)
%ISVALID Determine if timer object is valid.
%
%    OUT = ISVALID(OBJ) returns a logical array, OUT, that contains 
%    a 0 where the elements of OBJ are invalid timer objects and a 1 
%    where the elements of OBJ are valid timer objects. 
%
%    An invalid timer object is an object that has been deleted and
%    cannot be reused. Use the CLEAR command to remove an invalid 
%    timer object from the workspace.
%
%    Example:
%      % Create a valid timer object.
%      t = timer;
%      out1 = isvalid(t)
%
%      % Delete the timer object, hence making it invalid.
%      delete(t)
%      out2 = isvalid(t)
%
%    See also TIMER/DELETE.
%

%    RDD 11-20-2001
%    Copyright 2001-2002 The MathWorks, Inc. 


% check each element in java object array to see if it is a timer object
isok = isJavaTimer(obj.jobject);
