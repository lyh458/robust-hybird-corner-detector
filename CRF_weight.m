function [ w ] = CRF_weight( CRF1, CRF2 )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
w = CRF1/(CRF1+CRF2);
end

