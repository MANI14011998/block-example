Blockly.JavaScript['play_sound'] = function(block) {
  var value = '\'' + block.getFieldValue('VALUE') + '\'';
  return 'MusicMaker.playSound(' + value + ');\n';
};
