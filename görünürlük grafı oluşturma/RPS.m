function [ edges ] = RPS( vertices )


   
    N = size(vertices,1);

  
    edges = [];
    
   
    edges_idx = 1;
    
    
    E = calculate_edges( vertices, N);
    
   
    figure;
    plot_environmnet( E, vertices );
    
  
    if( isempty(E) ); edges = [1,2]; plot_result( edges, vertices ); return; end;
    
   
    for i=1:N
        
      
        v = vertices(i,:);

        
        subset = [vertices(1:i-1,:); vertices(i+1:N,:)];

        
        A = calculate_alpha( v, subset );

       
        [S, E_dst] = intersects_line( v, vertices, E )
        
       
        for j=1:N-1
            
           
            if (A(j)<i); vertex_nr = A(j); else vertex_nr = A(j) + 1; end;
            
           
            vi = subset(A(j),:);
            
           
            [edges, edges_idx] = add_edge(S, v, vi, E, vertices, E_dst, ...
                                          vertex_nr, edges_idx, edges, i);
                                 
           
            start_edge = find( E(:,1) == vertex_nr );
            
           
            end_edge = find( E(:,2) == vertex_nr );
            
           
            [insert_edges, delete_edges] = find_edges(v,vi,start_edge,end_edge,E,vertices);
            
         
            if ~isempty( insert_edges)
                
                [S, E_dst] = insert_edge(v, vi, insert_edges, E_dst, S, vertices);
            end
            
            
            if ~isempty( delete_edges)
               
                [S, E_dst] = delete_edge(delete_edges, E, E_dst, S);
            end
        end   
    end
    
   
    edges = clear_edges(edges, vertices, E);
    
  
    plot_result( edges, vertices );
   
    plot_environmnet( E, vertices );
    
end

function [edges, edges_idx] = add_edge(S, v, vi, E, vertices, E_dst, vertex_nr, edges_idx, edges, i)


    if ( ~isempty( S) )
   
        if is_visible(v, vi, S, E, vertices, E_dst)
           
            edges(edges_idx,:) = [i, vertex_nr];                    
            edges_idx = edges_idx + 1;
        end
    else
           
            edges(edges_idx,:) = [i, vertex_nr];
            edges_idx = edges_idx + 1;
    end
                                 
end

function [ insert_edges, delete_edges ] = find_edges( v, vi, start_idx, end_idx, E, vertices)


    insert_edges = [];
    delete_edges = [];

    proj_start = 0;
    proj_end = 0;
    
    line_v_vi_hmg =  homogeneous_coordinates( [v(1) v(2) vi(1) vi(2)] );
    line_v_vi_hmg = line_v_vi_hmg ./ sqrt( line_v_vi_hmg(1).^2 + line_v_vi_hmg(2).^2);
    
    vertex_start = [vertices( E(start_idx,2), 1:2), 1];
    vertex_end = [vertices( E(end_idx,1), 1:2), 1];
   
    if( ~isempty(start_idx) )
        proj_start = dot(line_v_vi_hmg, vertex_start);
    end
    
    if( ~isempty(end_idx) )
        proj_end = dot(line_v_vi_hmg, vertex_end)
    end

    insert_idx = 1;
    delete_idx = 1;
    
    if( proj_start > 0  )
        insert_edges( insert_idx ) = start_idx;   
        insert_idx = insert_idx + 1;
    end
    if( proj_start < 0 ) 
        delete_edges( delete_idx ) = start_idx;   
        delete_idx = delete_idx + 1;
    end
    
    if( proj_end > 0  )
        insert_edges( insert_idx ) = end_idx;   
        insert_idx = insert_idx + 1;
    end
    if( proj_end < 0 ) 
        delete_edges( delete_idx ) = end_idx;   
        delete_idx = delete_idx + 1;
    end

end

function [ E ] = calculate_edges( vertices, N )
    E =[];
    edge_idx = 1;

    for i=2:N-1
        
        
        object_nr = vertices(i,3);
        
        
        if ( vertices(i-1,3) ~= object_nr )
         
            init_vertex_idx = i;
        end
        
        
        if ( vertices(i+1,3) == object_nr )
           
            E(edge_idx,:) = [i, i+1];
        else
           
            E(edge_idx,:) = [i, init_vertex_idx];
        end
        
        edge_idx = edge_idx + 1;
        
    end
    
end


function [ A ] = calculate_alpha( v, vertices )

   
    N = size(vertices,1);
    
   
    for i=1:N
        x = vertices(i,1) - v(1);
        y = vertices(i,2) - v(2);
        
        alpha(i,1) = atan2( y, x );
    end
    
   
    alpha = mod(alpha,2*pi);
    
   
    [sorted_alpha, A] = sort(alpha(:),'ascend');
    
    
    A = A';
    
end

function [ S, sorted_E_dst ] = intersects_line( v, vertices, E )


  
    E_dst = [];
    S = [];

   
    N = size(E,1);

   
    [~, max_idx] = max(vertices(:,1));
    
 
    line_v = [v(1) v(2) vertices(max_idx,1) v(2)];
    
   
    s_idx = 1;
    
  
    for i=1:N
    
   
        line = [vertices( E(i,1), 1:2),  vertices( E(i,2), 1:2)];
        
        
        [ intersect , dst] = is_intersected(line_v, line, E, vertices);
        
        
        if intersect
            
            
            if abs( homogeneous_coordinates(line_v) - homogeneous_coordinates(line) ) > 0.00001
                
                S(s_idx) = i;
                
                E_dst(s_idx) = dst;
                s_idx = s_idx + 1;
            end
      
        end
        
    end

    
    [sorted_E_dst, sorted_idx] = sort(E_dst(:),'ascend');
    sorted_E_dst = sorted_E_dst';

   
    S = S(sorted_idx');
  
end

function [ intersect, dst ] = is_intersected(line_1, line_2, E, vertices)

    dst = 0;

    
    line_hmg_1 = homogeneous_coordinates( line_1 );
    
   
    line_hmg_2 = homogeneous_coordinates( line_2 );
    
    
    intersect_pt = cross(line_hmg_1,line_hmg_2);
    
    if intersect_pt(3) == 0
        intersect = false;
    else
       
        intersect_pt = intersect_pt ./ intersect_pt(3);
        
      
        x = intersect_pt(1);
        
       
        x_line_1 = sort([line_1(1), line_1(3)],'ascend');
        x_line_2 = sort([line_2(1), line_2(3)],'ascend');
        
       
        if ( is_an_edge( intersect_pt, E, vertices, line_1) || ...
             is_an_edge( intersect_pt, E, vertices, line_2)  )
            intersect = false;
        else
         
            if ( ( x >= x_line_1(1) ) && ( x <= x_line_1(2) ) && ...
                 ( x >= x_line_2(1) ) && ( x <= x_line_2(2) ) )
                intersect = true;
               
                dst = norm((intersect_pt(1:2) - line_1(1:2)),2);
            else
                intersect = false;
            end
        end
        
    end
    
end

function [ edge ] = is_an_edge( intersect_pt, E, vertices, line )


     diff_x_line_1 = abs( intersect_pt(1) - line(1) );
     diff_y_line_1 = abs( intersect_pt(2) - line(2) );
     diff_x_line_2 = abs( intersect_pt(1) - line(3) );
     diff_y_line_2 = abs( intersect_pt(2) - line(4) );
     
     if( ( ( diff_x_line_1 < 0.0001 ) && ( diff_y_line_1 < 0.0001 ) ) || ...
         ( ( diff_x_line_2 < 0.0001 ) && ( diff_y_line_2 < 0.0001 ) ) )
        edge = true;
     else
         edge = false;
     end

end

function [hmg] = homogeneous_coordinates( line )


    a = line(2) - line(4);
    b = line(3) - line(1);
    c = ( line(1) * line(4) ) - ( line(3) * line(2) );

    hmg = [a, b, c];
end

function [ visible ] = is_visible(v, vi, S, E, vertices, E_dst)
i
    dst = norm((v(1:2) - vi(1:2)),2);
    
   
    N = size(S,2);
    
  
    S_idx = 1;
    
   
    visible = true;
    
   
    line_v_vi = [v(1) v(2) vi(1) vi(2)];
    
 
    while ( ( S_idx <= N ) )
        
        E_idx = S(S_idx)
        
        line_e = [vertices( E(E_idx,1), 1:2),  vertices( E(E_idx,2), 1:2)];
        
        [ intersect , ~] = is_intersected(line_v_vi, line_e, E, vertices);
        
        if( intersect )
            visible = false;
            break;
        end
        
        S_idx = S_idx + 1;
        
    end

end

function [ S, E_dst ] = insert_edge(v, vi, edges_insrt, E_dst, S, vertices)

    N = size(edges_insrt,2);
    
    for i=1:N
        
       
        if isempty( find(S(:) == edges_insrt(i) ) )
        
         
            dst = norm((v(1:2) - vi(1:2)),2);

           
            smaller_idx = E_dst(:) <= dst;
            bigger_idx = E_dst(:) > dst;
            
            
            S = [S(smaller_idx'), edges_insrt(i), S(bigger_idx') ];
            
            
            E_dst = [E_dst(smaller_idx'), dst, E_dst(bigger_idx')];
        end
            
    end

end

function [ S_out, E_dst_out ] = delete_edge(edges_dlt, E, E_dst, S);

    N = size(edges_dlt,2);
    
    S_size = size(S,2);
    
    S_out = S;
    E_dst_out = E_dst;
    
    for i=1:N
        
        if ~( isempty( find(S_out(:) == edges_dlt(i)) ) )
            
            idx_S = find( S_out(:) == edges_dlt(i) );
            
            S_out(idx_S) = [];
            E_dst_out(idx_S) = [];
        

        end
        
    end

end

function [edges] = clear_edges(edges, vertices, E)


    edge_idx = 1;
    
   
    for i=1:size(edges,1)
        if ( vertices( edges(edge_idx,1),3 ) == vertices( edges(edge_idx,2),3 ) )
            edges(edge_idx,:) = [];
        else
            edge_idx = edge_idx + 1;
        end
    end
    
    edges = [edges; E];
    edges = sortrows(edges);

end

function plot_environmnet( E, vertices )


    
    plot( vertices(1,1), vertices(1,2), 'ro', 'MarkerFaceColor',[1,0,0], ...
          'MarkerSize', 8 );
    hold on;
    
    plot( vertices(end,1), vertices(end,2), 'go', 'MarkerFaceColor',[0,1,0], ...
          'MarkerSize', 8 );
    hold on;
    
    for i=1:size(E,1)
        plot([vertices( E(i,1), 1); vertices( E(i,2), 1)],...
             [vertices( E(i,1), 2); vertices( E(i,2), 2)],...
             'bo', 'MarkerFaceColor',[0,0,1]);
        hold on;
        plot([vertices( E(i,1), 1); vertices( E(i,2), 1)],...
             [vertices( E(i,1), 2); vertices( E(i,2), 2)]);
        hold on;
    end
    
end

function plot_result( edges, vertices )


    for n=1:size(edges,1)
        plot([vertices( edges(n,1), 1); vertices( edges(n,2), 1)],...
             [vertices( edges(n,1), 2); vertices( edges(n,2), 2)],...
             '-r');
        hold on;
    end
    
end

function [ vertices ] = environment( )

    vertices = zeros(10,3);

    [x,y] = ginput(10);

    vertices(1,:) = [x(1) y(1) 0];
    vertices(2:5,:) = [x(2:5) y(2:5) ones(4,1)];
    vertices(6:9,:) = [x(6:9) y(6:9) (ones(4,1).*2)];
    vertices(10,:) = [x(10) y(10) 3];

    plot( x(1), y(1), 'bo' )
    hold on;
    plot([x(2:5); x(2)],[y(2:5); y(2)]);
    hold on;
    plot([x(6:9); x(6)],[y(6:9); y(6)]);
    hold on;
    plot(x(10),y(10), 'ro');

end