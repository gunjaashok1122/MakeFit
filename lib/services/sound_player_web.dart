import 'dart:js' as js;

void playAlarmSoundWeb() {
  try {
    js.context.callMethod('eval', [
      """
      (function() {
        var context = new (window.AudioContext || window.webkitAudioContext)();
        
        var playTone = function(freq, startOffset, dur) {
          var osc = context.createOscillator();
          var gain = context.createGain();
          osc.connect(gain);
          gain.connect(context.destination);
          
          osc.type = 'sine';
          osc.frequency.setValueAtTime(freq, context.currentTime + startOffset);
          gain.gain.setValueAtTime(0.4, context.currentTime + startOffset);
          gain.gain.exponentialRampToValueAtTime(0.001, context.currentTime + startOffset + dur);
          
          osc.start(context.currentTime + startOffset);
          osc.stop(context.currentTime + startOffset + dur + 0.05);
        };
        
        // Play 3 alarm beeps (same as preview mockup)
        playTone(880, 0, 0.18);
        playTone(880, 0.22, 0.18);
        playTone(1100, 0.44, 0.40);
      })()
      """
    ]);
  } catch (e) {
    print('Web Audio error: \$e');
  }
}
