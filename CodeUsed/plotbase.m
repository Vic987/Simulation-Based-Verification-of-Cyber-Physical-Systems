% Plot riservato al caso base
%
%

i = 1;
table = readtable("test_result15.csv");
if(i == 1)
	plot([table.(1)], [table.(3)], "Marker", ".");
	title("% di acceleratore controesempio caso base");
	xlabel("Tempo");
	ylabel("% di acceleratore");
	legend("Throttle controesempio", "Location", "southwest");
elseif(i == 2)
	plot([table.(1)], [table.(4)], "Marker", ".");
	title("Numero di giri controesempio caso base");
	xlabel("Tempo");
	ylabel("RPM");
	legend("EngineRPM controesempio", "Location", "southwest");
else
	plot([table.(1)], [table.(5)], "Marker", ".");
	title("Velocità controesempio caso base");
	xlabel("Tempo");
	ylabel("Km/h");
	legend("Velocità controesempio", "Location", "southwest");
end

x0=20;
y0=20;
width=850;
height=700;
set(gcf,'position',[x0,y0,width,height]);

clear;
