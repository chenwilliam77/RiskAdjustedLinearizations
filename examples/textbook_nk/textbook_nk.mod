var N C w R Pi mc A v Pir x1 x2 c r pi;

varexo eA eR;

parameters epsi phi sigma eta beta psi rhoA rhoR phipi sA sR;

beta = .99;
epsi = 4.45;
sigma = 2.0;
eta = 1.0;
psi = 1.0;
phi = 0.7;
phipi = 1.5;
rhoA = .9;
rhoR = 0.7;
sA = 0.004;
sR = .025 / 4.0;

model;

% (1) Labor supply
psi*N^(eta)/w = C^(-sigma);

% (2) Euler equation bonds
1 = beta*(C(+1)^(-sigma)/C^(-sigma)*R/Pi(+1));

% (3) Marginal cost
mc = w/A;

% (4) Market-clearing for consumption
1 = A*N/(v*C);

% (5) optimal reset
Pir = (epsi/(epsi-1))*x1/x2*Pi;

% (6) Price dispersion
v = Pi^(epsi)*((1-phi)*Pir^(-epsi)+phi*v(-1));

% (7) Phillips curve
Pi^(1-epsi) = (1-phi)*Pir^(1-epsi)+phi;

% (8) x1
x1 = C^(1-sigma)*mc + phi*beta*Pi(+1)^(epsi)*x1(+1);

% (9) x2
x2 = C^(1-sigma) + phi*beta*Pi(+1)^(epsi-1)*x2(+1);

% (10) Taylor rule
log(R) = (1-rhoR)*log(1/beta) + rhoR*log(R(-1)) + (1-rhoR)*phipi*log(Pi) + sR*eR;

% (11) Process for A
log(A) = rhoA*log(A(-1)) + sA*eA;

c = log(C);

pi = log(Pi);

r = log(R);

end;

initval;
A = 1;
N = 1;
mc = (epsi-1)/epsi;
w = (epsi-1)/epsi;
C = 1;
R = 1/beta;
v = 1;
Pi = 1;
Pir = 1;
x1 = (1*(epsi-1)/epsi)/(1-phi*beta);
x2 = 1/(1-phi*beta);
c = 0;
pi = 0;
r = 0;
end;

shocks;
var eA = 1;
var eR = 1;
end;

steady;
