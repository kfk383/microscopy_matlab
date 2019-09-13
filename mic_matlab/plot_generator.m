% plot generator

AA = load('area_GO.txt');

mean_area = mean(AA)
standard_dev = std(AA)

[n h] = hist(AA,200);

bar(h,n./sum(n), 0.75,'hist');

set(gca,'FontSize',20)
xlabel('Area of particles [\mum^2]','FontSize',25)
xlim([0 100])
ylabel('fraction','FontSize',25)