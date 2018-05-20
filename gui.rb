require 'tk'
require 'tkextlib/tile'

root = TkRoot.new {title "rbMultiDownloader"}
content = Tk::Tile::Frame.new() {padding "3 3 12 12"}.grid( :sticky => 'nsew')
TkGrid.columnconfigure root, 0, :weight => 1; TkGrid.rowconfigure root, 0, :weight => 1

$status = TkVariable.new
f = Tk::Tile::Entry.new(content) {width 64; textvariable $url}.grid( :column => 2, :row => 1, :sticky => 'we' )
Tk::Tile::Label.new(content) {textvariable $status}.grid( :column => 2, :row => 2, :sticky => 'we');
Tk::Tile::Button.new(content) {text 'Download'; command {download}}.grid( :column => 3, :row => 3, :sticky => 'w')

Tk::Tile::Label.new(content) {text 'URL: '}.grid( :column => 1, :row => 1, :sticky => 'w')

TkWinfo.children(content).each {|w| TkGrid.configure w, :padx => 5, :pady => 5}
f.focus
root.bind("Return") {download}

def download
  begin
    $status.value = 'OK'
  rescue
    $status.value = ''
  end
end

Tk.mainloop