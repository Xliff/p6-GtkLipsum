use v6.c;

use Cro::HTTP::Client;
use XML::XPath;

use GTK::Adjustment;
use GTK::Application;
use GTK::Builder;

my $a = GTK::Application.new( title => 'org.genex.gtk_ipsum' );
my $b = GTK::Builder.new( pod => $=pod );
my @options = [
  bytes => 27..71680,
  words => 5..10000,
  paras => 1..150,
  lists => 1..150,
];

sub retrieve-ipsum {
  $b<ProgressBar>.show_text = False;
  $b<DebugTextView>.buffer.text = '';

  my $canceller = $*SCHEDULER.cue({ $b<ProgressBar>.pulse }, every => 0.1);
  my $what = @options[ $b<TypeCombo>.active ].key;
  my $amount = $b<LengthSpin>.value;
  my $start = $b<StartWithCheckButton>.active;
  my $url = qq:to/URL/.chomp;
http://lipsum.com//feed/xml?what={$what}\&amount={$amount}\&start={$start.Int}
URL

  $b<DebugTextView>.buffer.append("Connecting to $url ...\n");
  my $resp;
  try {
    CATCH {
      $b<DebugTextView>.buffer.append( "Error!\n{ .message }\n" );
      $resp = Nil;
    }
    $resp = await Cro::HTTP::Client.get($url);
  }
  return unless $resp;
  my $body = await $resp.body;
  $b<DebugTextView>.buffer.append( "OK.\nParsing...\n" );
  my $xml-parser = XML::XPath.new( xml => $body );
  $b<OutputTextView>.buffer.text = do {
    my $b = $what eq 'lists' ?? '* ' !! '';
    $xml-parser.find('//feed/lipsum/text()').text.lines.
      map({ "\t{ $b }$_\n" }).
      join("\n");
  }
  $b<ProgressBar>.show_text = True;
  $b<ProgressBar>.text = $xml-parser.find('/feed/generated/text()').text;
  $b<DebugTextView>.buffer.append("Done.");
  $canceller.cancel;
}

sub typecombo_changed {
  my $range = @options[ $b<TypeCombo>.active ].value;
  my $v = ($range.min, $b<LengthSpin>.value).max;
  my $a = GTK::Adjustment.new($v, $range.min, $range.max, 1, 10, 0);
  $b<LengthSpin>.set_range($range.min, $range.max);
  $b<LengthSpin>.adjustment = $a;
}

$a.activate.tap({
  $b<MainWindow>.title = 'Lipsum.com P6-GTK Interface';
  $b<DebugExpander>.label = 'Debug';
  $b<OutputTextView>.text =
    'Choose the amount of lipsum you want, then click Apply';

  $b<ReadOnlyCheckButton>.clicked.tap({
    $b<OutputTextView>.editable = $b<ReadOnlyCheckButton>.active.not
  });

  $b<GenerateButton>.clicked.tap({ retrieve-ipsum() });

  $b<MainWindow>.destroy-signal.tap({ $a.exit });
  $b<TypeCombo>.append_text($_) for @options.map( *.keys ).flat;
  $b<TypeCombo>.active = 2;
  $b<TypeCombo>.changed.tap({ typecombo_changed() });
  typecombo_changed();

  $b<MainWindow>.show-all;
});

$a.run;

=begin ui
<?xml version="1.0" encoding="UTF-8"?>
<!-- Generated with glade 3.22.1 -->
<interface>
  <requires lib="gtk+" version="3.0"/>
  <object class="GtkWindow" id="MainWindow">
    <property name="visible">True</property>
    <property name="can_focus">False</property>
    <property name="title" translatable="yes">Lipsum.com rgtk interface</property>
    <property name="default_width">500</property>
    <property name="default_height">300</property>
    <signal name="destroy" handler="on_MainWindow_destroy" swapped="no"/>
    <child>
      <placeholder/>
    </child>
    <child>
      <object class="GtkBox" id="vbox1">
        <property name="visible">True</property>
        <property name="can_focus">False</property>
        <property name="border_width">4</property>
        <property name="orientation">vertical</property>
        <property name="spacing">4</property>
        <child>
          <object class="GtkBox" id="hbox3">
            <property name="visible">True</property>
            <property name="can_focus">False</property>
            <property name="spacing">10</property>
            <child>
              <object class="GtkBox" id="vbox3">
                <property name="visible">True</property>
                <property name="can_focus">False</property>
                <property name="orientation">vertical</property>
                <child>
                  <object class="GtkBox" id="hbox1">
                    <property name="visible">True</property>
                    <property name="can_focus">False</property>
                    <property name="spacing">4</property>
                    <child>
                      <object class="GtkLabel" id="label1">
                        <property name="visible">True</property>
                        <property name="can_focus">False</property>
                        <property name="xpad">0</property>
                        <property name="ypad">0</property>
                        <property name="label" translatable="yes">Length:</property>
                        <property name="xalign">0.5</property>
                        <property name="yalign">0.5</property>
                      </object>
                      <packing>
                        <property name="expand">False</property>
                        <property name="fill">False</property>
                        <property name="position">0</property>
                      </packing>
                    </child>
                    <child>
                      <object class="GtkSpinButton" id="LengthSpin">
                        <property name="visible">True</property>
                        <property name="can_focus">True</property>
                        <property name="climb_rate">1</property>
                        <signal name="changed" handler="on_LengthSpin_changed" swapped="no"/>
                      </object>
                      <packing>
                        <property name="expand">True</property>
                        <property name="fill">True</property>
                        <property name="position">1</property>
                      </packing>
                    </child>
                    <child>
                      <object class="GtkComboBoxText" id="TypeCombo">
                        <property name="visible">True</property>
                        <property name="can_focus">False</property>
                      </object>
                      <packing>
                        <property name="expand">True</property>
                        <property name="fill">True</property>
                        <property name="position">2</property>
                      </packing>
                    </child>
                  </object>
                  <packing>
                    <property name="expand">True</property>
                    <property name="fill">True</property>
                    <property name="position">0</property>
                  </packing>
                </child>
                <child>
                  <object class="GtkCheckButton" id="StartWithCheckButton">
                    <property name="label" translatable="yes">Start with "Lorem ipsum dolor sit amet..."</property>
                    <property name="visible">True</property>
                    <property name="can_focus">True</property>
                    <property name="receives_default">False</property>
                    <property name="use_underline">True</property>
                    <property name="active">True</property>
                    <property name="draw_indicator">True</property>
                  </object>
                  <packing>
                    <property name="expand">False</property>
                    <property name="fill">False</property>
                    <property name="position">1</property>
                  </packing>
                </child>
              </object>
              <packing>
                <property name="expand">True</property>
                <property name="fill">True</property>
                <property name="position">0</property>
              </packing>
            </child>
            <child>
              <object class="GtkButton" id="GenerateButton">
                <property name="label">gtk-apply</property>
                <property name="visible">True</property>
                <property name="can_focus">True</property>
                <property name="receives_default">False</property>
                <property name="use_stock">True</property>
                <signal name="clicked" handler="on_GenerateButton_clicked" swapped="no"/>
              </object>
              <packing>
                <property name="expand">False</property>
                <property name="fill">False</property>
                <property name="position">1</property>
              </packing>
            </child>
          </object>
          <packing>
            <property name="expand">False</property>
            <property name="fill">True</property>
            <property name="position">0</property>
          </packing>
        </child>
        <child>
          <object class="GtkScrolledWindow" id="scrolledwindow1">
            <property name="visible">True</property>
            <property name="can_focus">True</property>
            <property name="hscrollbar_policy">never</property>
            <property name="vscrollbar_policy">always</property>
            <property name="shadow_type">in</property>
            <child>
              <object class="GtkTextView" id="OutputTextView">
                <property name="visible">True</property>
                <property name="can_focus">True</property>
                <property name="editable">False</property>
                <property name="wrap_mode">word</property>
              </object>
            </child>
          </object>
          <packing>
            <property name="expand">True</property>
            <property name="fill">True</property>
            <property name="position">1</property>
          </packing>
        </child>
        <child>
          <object class="GtkBox" id="hbox4">
            <property name="visible">True</property>
            <property name="can_focus">False</property>
            <child>
              <object class="GtkProgressBar" id="ProgressBar">
                <property name="visible">True</property>
                <property name="can_focus">False</property>
                <property name="pulse_step">0.050000000745099998</property>
              </object>
              <packing>
                <property name="expand">True</property>
                <property name="fill">True</property>
                <property name="position">0</property>
              </packing>
            </child>
            <child>
              <object class="GtkCheckButton" id="ReadOnlyCheckButton">
                <property name="label" translatable="yes">read only</property>
                <property name="visible">True</property>
                <property name="can_focus">True</property>
                <property name="receives_default">False</property>
                <property name="use_underline">True</property>
                <property name="active">True</property>
                <property name="draw_indicator">True</property>
                <signal name="toggled" handler="on_ReadOnlyCheckButton_toggled" swapped="no"/>
              </object>
              <packing>
                <property name="expand">False</property>
                <property name="fill">False</property>
                <property name="position">1</property>
              </packing>
            </child>
          </object>
          <packing>
            <property name="expand">False</property>
            <property name="fill">False</property>
            <property name="position">2</property>
          </packing>
        </child>
        <child>
          <object class="GtkExpander" id="DebugExpander">
            <property name="visible">True</property>
            <property name="can_focus">True</property>
            <child>
              <object class="GtkScrolledWindow" id="scrolledwindow2">
                <property name="visible">True</property>
                <property name="can_focus">True</property>
                <property name="hscrollbar_policy">never</property>
                <property name="shadow_type">in</property>
                <child>
                  <object class="GtkTextView" id="DebugTextView">
                    <property name="visible">True</property>
                    <property name="can_focus">True</property>
                    <property name="editable">False</property>
                    <property name="wrap_mode">word</property>
                  </object>
                </child>
              </object>
            </child>
          </object>
          <packing>
            <property name="expand">False</property>
            <property name="fill">True</property>
            <property name="position">3</property>
          </packing>
        </child>
      </object>
    </child>
  </object>
</interface>
=end ui
