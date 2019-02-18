
drawnow;
plot3(Y{Count,k},Time,X{Count,k},'X','Color','blue')
axis([0 720 0 inf 0 1280])
grid on; hold on; title ('Motion Trajectory');
xlabel('Y area'); ylabel('Time'); zlabel('X area');