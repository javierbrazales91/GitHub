/*---------------------------------------------------------------------
This is the master program which will call all the programs to run for
 results for the HWK01 of Development Economics at CEMFI

2019 Winter by Prof. Raul Santaeulalia-Llopis 

Hefang Deng (hefang.deng@cemfi.edu.es)
Updated January 20, 2019 
---------------------------------------------------------------------*/

/*===========================*/	
// section 1: initialization
clear all
macro drop _all
set more off
set matsize 11000
set maxvar 20000
//
// STOP!!! Change the following line so that it refers to the proper folder in your computer!!!
//
global Path "C:\Users\CEMFI\Dropbox\00_S5\GitHub\Development-Economics\HWK01"
global DataPath "$Path\Data"
global CodesPath "$Path\Codes"
global DocPath "$Path\Doc"

cd "$CodesPath"

/*===========================*/

quietly do 001_Data.do
quietly do 002_Q1.do
quietly do 003_Q2.do
quietly do 004_Q3.do

