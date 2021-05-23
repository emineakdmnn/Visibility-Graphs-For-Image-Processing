clear; close all; clc;


vertices = load('vertices2.mat');
vertices = vertices.vertices

[ edges ] = RPS( vertices )