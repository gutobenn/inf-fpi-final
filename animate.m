function f = animate(filename, SegLen, widthFactor, optimized)
    % Init some constants
    BLACK = [0 0 0];
    BLUE = [0.2 0.2 1];%[0 102 255];
    WHITE = [255 254 254];
    YELLOW = [1.0 0.8 0.0]; %[210 210 0];
    COLORS = [BLACK; BLUE; BLUE; WHITE; YELLOW; YELLOW];
    
    Rows = 512;
    Cols = 512;
    Channels = 3;
    
    if rem(SegLen,6) ~= 0
        disp('SegLen must be multiple of 6!')
        return;
    end
    
    % Create black image
    I(1:Rows, 1:Cols, 1:Channels) = 127;
    
    fileID = fopen(filename,'r');
    % Read the number of streamlines
    N = fscanf(fileID, '%d', 1);
    for i=1:N
        % Read the number of points for current streamline
        P = fscanf(fileID, '%d', 1);
        
        points = [];
        for j=1:P
            % Read current point coordinates and insert into 'points'
            X = uint16(1 + fscanf(fileID, '%f', 1));
            Y = uint16(1 + fscanf(fileID, '%f', 1));
            points = [points; [X Y]];
        end
        
        % simulate three draws and find out which is the best
        min_counter = Rows * Cols;
        best_offset = 0;
        if optimized > 0
            for offset=-1:1
                counter = 0;
                disp(i)
                for j=1:P
                    X = points(j,1);
                    Y = points(j,2);
                    index = floor(rem(j+offset,SegLen) * (6/SegLen)+1);
                    for c=1:Channels
                        width = floor(1 + widthFactor*SegLen);
                        for m=-width:width
                            for n=-width:width
                                if (abs(m) > abs(n) && (X+m >= 1 && Y+n >= 1 && X+m <= Rows && Y+n <= Cols))
                                    if ( (( isequal(COLORS(index),WHITE) || isequal(COLORS(index),YELLOW)) && ( isequal(I(X+m, Y+n), WHITE) || isequal(I(X+m, Y+n),YELLOW))) || ((isequal(COLORS(index),BLACK) || isequal(COLORS(index),BLUE)) && (isequal(I(X+m, Y+n),BLACK) || isequal(I(X+m, Y+n),BLUE) )) )
                                        counter = counter + 1;
                                    end
                                end
                            end
                        end
                    end
                end
                if counter < min_counter
                    min_counter = counter;
                    best_offset = offset;
                end
            end
        end
        
        % finally draw it (with a circular (actually, triangular)neighborhood)
        for j=1:P
            X = points(j,1);
            Y = points(j,2);
            index = floor(rem(j+best_offset,SegLen) * (6/SegLen)+1);
            for c=1:Channels
                width = floor(1 + widthFactor*SegLen);
                for m=-width:width
                    for n=-width:width
                        if (abs(m) > abs(n) && (X+m >= 1 && Y+n >= 1 && X+m <= Rows && Y+n <= Cols))
                            I(X+m,Y+n,c) = COLORS(index,c);
                        end
                    end
                end
            end
        end
    end
    fclose(fileID);
    
    imshow(I);
end
