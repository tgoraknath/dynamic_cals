class String    
  def black;          "\e[30m#{self}\e[0m" end
  def red;            "\e[31m#{self}\e[0m" end
  def gray;           "\e[37m#{self}\e[0m" end

  def bg_brown;       "\e[43m#{self}\e[0m" end
  def bg_gray;        "\e[47m#{self}\e[0m" end
  def bg_red;        "\e[41m#{self}\e[0m" end

  def bold;           "\e[1m#{self}\e[22m" end
  def blink;          "\e[5m#{self}\e[25m" end
  def reverse_color;  "\e[7m#{self}\e[27m" end
end