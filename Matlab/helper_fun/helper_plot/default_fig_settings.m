% =====================================================================================
% Author:       Orhan Soyuhos 
% Last Modified: 08/01/2025
% =====================================================================================

function default_fig_settings()
    % Sets default figure properties for a consistent look.

    % Define a scale factor based on the desired reduction
    scale_factor = 12 / 16;
    
    % Set default font sizes
    set(groot, 'DefaultAxesFontSize', 18 * scale_factor);
    set(groot, 'DefaultLegendFontSize', 16 * scale_factor);
    set(groot, 'DefaultAxesLabelFontSizeMultiplier', (20 * scale_factor) / (18 * scale_factor));
    set(groot, 'DefaultAxesTitleFontSizeMultiplier', (22 * scale_factor) / (18 * scale_factor));
    
    % Set figure size using a widescreen aspect ratio
    % We get the screen size to position the figure nicely
    screen_size = get(groot, 'ScreenSize');
    fig_width = 1200; % pixels
    fig_height = 1200/16*9; % pixels
    pos = [(screen_size(3)-fig_width)/2, (screen_size(4)-fig_height)/2, fig_width, fig_height];
    set(groot, 'DefaultFigurePosition', pos);
    
    % Set seaborn 'white' style
    set(groot, 'DefaultFigureColor', 'w');
    set(groot, 'DefaultAxesColor', 'w');
    set(groot, 'DefaultAxesXColor', 'k');
    set(groot, 'DefaultAxesYColor', 'k');
    set(groot, 'DefaultAxesZColor', 'k');
    set(groot, 'DefaultTextColor', 'k');
    set(groot, 'DefaultAxesBox', 'on');
    set(groot, 'DefaultAxesXGrid', 'off');
    set(groot, 'DefaultAxesYGrid', 'off');

    % Set seaborn 'muted' palette as the default color order
    muted_palette = [
        0.2824, 0.4706, 0.8118; % Muted Blue
        0.4157, 0.8000, 0.3961; % Muted Green
        0.8392, 0.3725, 0.3725; % Muted Red
        0.7059, 0.4863, 0.7804; % Muted Purple
        0.7686, 0.6784, 0.4000; % Muted Yellow
        0.4667, 0.7451, 0.8627  % Muted Cyan
    ];
    set(groot, 'DefaultAxesColorOrder', muted_palette);
end

%% Orhan Soyuhos, 2025