# reference : http://clintbellanger.net/articles/isometric_math/

require 'gosu'

class Window < Gosu::Window
    def initialize
        super(640, 480, false)
        @selected = nil
        @window_scale = 2
    end

    def button_down(id)
        super
        close! if id == Gosu::KB_ESCAPE
    end

    def needs_cursor?; true; end

    def update
        @iso_tile ||= Gosu::Image.new('./tile.png', retro: true)

        @origin_x ||= 200
        @origin_y ||= 20

        @origin_x -= 1 if Gosu::button_down?(Gosu::KB_D)
        @origin_x += 1 if Gosu::button_down?(Gosu::KB_A)
        @origin_y -= 1 if Gosu::button_down?(Gosu::KB_S)
        @origin_y += 1 if Gosu::button_down?(Gosu::KB_W)

        pick_tile(self.mouse_x / @window_scale, self.mouse_y / @window_scale)
    end

    def pick_tile(screen_x, screen_y)
        half_tile_width = @iso_tile.width / 2
        half_tile_height = @iso_tile.height / 2

        z = ((screen_y - @origin_y) / half_tile_height - (screen_x - @origin_x) / half_tile_width) / 2
        x = z + (screen_x - @origin_x) / half_tile_width

        @selected = [x.floor, z.floor]
    end

    def project(x, z)
        half_tile_width = @iso_tile.width / 2
        half_tile_height = @iso_tile.height / 2

        x_coords = @origin_x + (x - z) * half_tile_width - half_tile_width
        y_coords = @origin_y + (x + z) * half_tile_height
        z_coords = 0
        return [x_coords, y_coords, z_coords]
    end

    def draw_cube(height, x, z)
        @cube_tiles ||= 
        [
            Gosu::Image.new('./cube1.png', retro: true),
            Gosu::Image.new('./cube2.png', retro: true),
            Gosu::Image.new('./cube3.png', retro: true)

        ]
        x_coords, y_coords, z_coords = project(x, z)
        @cube_tiles[height - 1].draw(x_coords, y_coords - @cube_tiles[height - 1].height + @iso_tile.height, z_coords)
    end 

    def draw_sprite(sprite, x, z)
        x_coords, y_coords, z_coords = project(x, z)
        sprite.draw(x_coords + (@iso_tile.width - sprite.width) / 2, y_coords - sprite.height + @iso_tile.height / 2, z_coords)
    end

    def draw
        render = Gosu::render(320, 240, retro: true) do
            # background fill
            Gosu::draw_rect(0, 0, self.width, self.height, Gosu::Color::GREEN)
            
            # origin point        
            origin_size = 4
            Gosu::draw_rect(@origin_x - origin_size / 2, @origin_y - origin_size / 2, origin_size, origin_size, Gosu::Color::BLUE)

            # map
            map_width, map_length = 20, 15

            map_width.times do |x|
                map_length.times do |z|
                    x_coords, y_coords, z_coords = project(x, z)
                    color = ([x, z] == @selected) ? Gosu::Color::RED : Gosu::Color::WHITE
                    @iso_tile.draw(x_coords, y_coords, z_coords, 1, 1, color)
                end
            end

            draw_cube(3, 5, 5)
            draw_cube(2, 7, 6)
            draw_cube(1, 10, 10)

            @sprite ||= Gosu::Image.new('./sprite.png', retro: true)
            draw_sprite(@sprite, 4, 12)
        end
        render.draw(0, 0, 0, @window_scale, @window_scale)
    end
end

Window.new.show