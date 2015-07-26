require 'rubygems'
require 'tach'

key = 'Content-Length'
value = '100'
Tach.meter(1_000) do
  tach('concat') do
    key << ': ' << value << "\r\n"
  end
  tach('interpolate') do
    "#{key}: value\r\n"
  end
end

# +-------------+----------+
# | tach        | total    |
# +-------------+----------+
# | concat      | 0.000902 |
# +-------------+----------+
# | interpolate | 0.019667 |
# +-------------+----------+