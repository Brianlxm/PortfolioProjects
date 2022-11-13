** data
cd "C:\Users\brian\Documents\ECO 480\Extra Credit Assignment 2"
do "C:\Users\brian\Documents\ECO 480\Extra Credit Assignment 2\cps_00004.do"

** Begin a log file
capture log close
log using "ExtraCreditAssignment2.log", replace

** drop irrelevant data
drop if incwage==99999999
drop if incwage==0

** create dummy variable for sex
gen byte sex1 = sex == 1 if !missing(sex)

** simple incwage sex reg
reg incwage sex1

** add age to reg
reg incwage sex1 age

** reg incwage sex age educ
reg incwage sex1 age educ

**
summarize

** generate race dummy variables
gen byte white = race == 100 if !missing(race)
gen byte black = race == 200 if !missing(race)
*american indian/aleut/eskimo
gen byte amind = race == 300 if !missing(race)
gen byte asian = race == 651 if !missing(race)

** reg incwage sex age educ race
reg incwage sex1 age educ white black amind asian

** reg adding hrs worked
reg incwage sex1 age educ white black amind asian uhrswork1 if inrange(uhrswork1,0,99)

** same reg but fulltime jobs only
reg incwage sex1 age educ white black amind asian uhrswork1 if inrange(uhrswork1,40,99)

** reg incwage sex age educ race hrswork highschoolgrad+
reg incwage sex1 age educ white black amind asian uhrswork1 if inrange(educ,73,125)

** highschoolgrad+ and fulltime
reg incwage sex1 age educ white black amind asian uhrswork1 if inrange(educ,73,125) & inrange(uhrswork1,40,99)

** dummy variables for education after highschoolgrad
gen byte highschoolgrad = educ == 73 if !missing(educ) 
gen byte somecollege = educ == 81 if !missing(educ)
gen byte assdocc = educ == 91 if !missing(educ)
gen byte assdap = educ == 92 if !missing(educ)
gen byte bachelor = educ == 111 if !missing(educ)
gen byte master = educ == 123 if !missing(educ)
gen byte prof = educ == 124 if !missing(educ)
gen byte doctor = educ == 125 if !missing(educ)

** regression with dummy variables for education level
reg incwage sex1 age white black amind asian uhrswork1 highschoolgrad somecollege assdocc assdap bachelor master prof doctor if inrange(uhrswork1,40,99)

** dummy variables for region
gen byte northeast = region == 11 | region == 12 if !missing(region)
gen byte midwest = region == 21 | region == 22 if !missing(region)
gen byte south = region == 31 | region == 32 | region == 33 if !missing(region)
gen byte west = region == 41 | region == 42 if !missing(region)

** adding region to existing reg omit midwest for multicollinearity
reg incwage sex1 age white black amind asian uhrswork1 highschoolgrad somecollege assdocc assdap bachelor master prof doctor northeast south west if inrange(uhrswork1,40,99)

** changing hours to overtime
gen byte overtime = uhrswork1 - 40 if !missing(uhrswork1)

** replacing hrs worked with overtime hrs
reg incwage sex1 age white black amind asian overtime highschoolgrad somecollege assdocc assdap bachelor master prof doctor northeast south west if inrange(uhrswork1,40,99)

** replacing base age with legal age 18
gen byte age18 = age - 18 if !missing(age)

reg incwage sex1 age18 white black amind asian overtime highschoolgrad somecollege assdocc assdap bachelor master prof doctor northeast south west if inrange(uhrswork1,40,99)

** trying without hrs worked
reg incwage sex1 age18 white black amind asian highschoolgrad somecollege assdocc assdap bachelor master prof doctor northeast south west if inrange(age,18,85)

** salary at age 30+ logic being midcareer
gen byte age30 = age - 30 if !missing(age)

reg incwage sex1 age30 white black amind asian highschoolgrad somecollege assdocc assdap bachelor master prof doctor northeast south west if inrange(age,30,85)

** average pregnancy age 26
gen byte age25 = age - 25 if !missing(age)
reg incwage sex1 age25 white black amind asian highschoolgrad somecollege assdocc assdap bachelor master prof doctor northeast south west if inrange(age,25,85)

** age 21
gen byte age21 = age - 21 if !missing(age)
reg incwage sex1 age21 white black amind asian highschoolgrad somecollege assdocc assdap bachelor master prof doctor northeast south west if inrange(age,21,85)

** minimum incwage for fulltime worker is $15,000
drop if incwage <= 15000
sum incwage

** fulltime incwage 
reg incwage sex1 age18 white black amind asian overtime highschoolgrad somecollege assdocc assdap bachelor master prof doctor northeast south west if inrange(uhrswork1,40,99)

** dummy variables for class of worker
gen byte private = classwkr == 21 if !missing(classwkr)
gen byte federalgov = classwkr == 25 if !missing(classwkr)
gen byte forces = classwkr == 26 if !missing(classwkr)
gen byte stategov = classwkr == 27 if !missing(classwkr)
gen byte localgov = classwkr == 28 if !missing(classwkr)

** reg with dummys for class of worker and not including self-employed
reg incwage sex1 age18 white black amind asian overtime highschoolgrad somecollege assdocc assdap bachelor master prof doctor northeast south west private federalgov stategov localgov if inrange(uhrswork1,40,99) & inrange(classwkr,21,28)

** figured out armed forces does not include hrsworked so reg without hrswork
reg incwage sex1 age18 white black amind asian highschoolgrad somecollege assdocc assdap bachelor master prof doctor northeast south west private federalgov stategov localgov if inrange(classwkr,21,28)

** armed forces not reliable for study omitted variable bias men more likely to join military around 85% male
** reg without forces and including hours again
reg incwage sex1 age18 white black amind asian overtime highschoolgrad somecollege assdocc assdap bachelor master prof doctor northeast south west private federalgov stategov localgov if inrange(classwkr,21,28) & inrange(uhrswork1,40,99) & forces !=1 & age >= 18

** adding dummys firm size
gen byte smallfirm = firmsize == 1 | firmsize == 2 | firmsize == 5 if !missing(firmsize)
gen byte medfirm = firmsize == 7 | firmsize == 8 if !missing(firmsize)
gen byte largefirm = firmsize == 9 if !missing(firmsize)

** reg including firmsize
reg incwage sex1 age18 white black amind asian overtime highschoolgrad somecollege assdocc assdap bachelor master prof doctor northeast south west private federalgov stategov localgov smallfirm medfirm largefirm if inrange(classwkr,21,28) & inrange(uhrswork1,40,99) & forces !=1 & age >= 18

** reg incwage, dummy for sex, var for age after 18, dummy for race, var for overtime hrs, dummys for educ levels, dummys for regions, dummys for classwkr types, dummys for firmsizes, constraints for not including self employed and armed forces, constraint for fulltime workers only 40+hrs, constraint for 18+ legal age

** constant being female, 18yrsold, not white black americanindian or asian, did not work overtime, did not graduate highschool, lives in midwest, works for stategov, works for smallfirm 
reg incwage sex1 age18 white black amind asian overtime highschoolgrad somecollege assdocc assdap bachelor master prof doctor northeast south west private federalgov localgov medfirm largefirm if inrange(classwkr,21,28) & inrange(uhrswork1,40,99) & forces !=1 & age >= 18

ssc inst groups

groups occ sex1, order(high)
groups occ sex if uhrswork1 >= 40, order(high)

** dummy variables for jobs with high male/female difference
gen byte malejob1 = occ == 9130 if !missing(occ)
gen byte femalejob1 = occ == 2310 if !missing(occ)
gen byte femalejob2 = occ == 3255 if !missing(occ)
gen byte femalejob3 = occ == 5700 if !missing(occ)
gen byte malejob2 = occ == 6260 if !missing(occ)

** adding job dummys with high male/female difference to existing regression
reg incwage sex1 age18 white black amind asian overtime highschoolgrad somecollege assdocc assdap bachelor master prof doctor northeast midwest south west private federalgov stategov localgov smallfirm medfirm largefirm malejob1 malejob2 femalejob1 femalejob2 femalejob3 if inrange(classwkr,21,28) & inrange(uhrswork1,40,99) & forces !=1 & age >= 18

** final reg incwage, dummy for sex, var for age after 18, dummy for race, var for overtime hrs, dummys for educ levels, dummys for regions, dummys for classwkr types, dummys for firmsizes, dummys for jobs with highest male/female difference, constraints for not including self employed and armed forces, constraint for fulltime workers only 40+hrs, constraint for 18+ legal age

** constant being female, 18yrsold, not white black americanindian or asian, did not work overtime, did not graduate highschool, lives in midwest, works for stategov, works for smallfirm, and does not work at a job with high male/female difference
reg incwage sex1 age18 white black amind asian overtime highschoolgrad somecollege assdocc assdap bachelor master prof doctor northeast south west private federalgov localgov medfirm largefirm malejob1 malejob2 femalejob1 femalejob2 femalejob3 if inrange(classwkr,21,28) & inrange(uhrswork1,40,99) & forces !=1 & age >= 18

sum incwage sex age race uhrswork1 educ region classwkr firmsize if inrange(classwkr,21,28) & inrange(uhrswork1,40,99) & forces !=1 & age >=18

sum incwage age uhrswork1 if inrange(classwkr,21,28) & inrange(uhrswork1,40,99) & age >=18
sum incwage age uhrswork1 if inrange(classwkr,21,28) & inrange(uhrswork1,40,99) & age >=18 & sex1 == 1
sum incwage age uhrswork1 if inrange(classwkr,21,28) & inrange(uhrswork1,40,99) & age >=18 & sex1 == 0