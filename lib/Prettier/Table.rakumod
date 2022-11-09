use Text::Wrap;
use Prettier::Table::Constrains;


unit class Prettier::Table:ver<1.1.0>:auth<masukomi (masukomi@masukomi.org)>;
#
# Public attributes
#

has $.title of Str;                        #= Optional table title
has @.field-names;                         #= List of field names (these are headers for their respective columns)
has @.fields;                              #= List of field names to include in displays from the available field names

has $.start of NonNeg = 0;                 #= Index of first data row to include in output.
has $.end = Inf;                           #= Index of last data row to include in output PLUS ONE (list slice style)

has $.header of Bool = True;               #= Print a heading showing the field names.
has $.header-style of HeaderStyle;         #= Style to apply to field names in header ("cap", "title", "upper", or "lower").
has $.border of Bool = True;               #= Print a border around the table.

has $.hrules of HorizontalRule = FRAME;    #= Control the printing of horizontal rules between rows. Allowed values: FRAME, HEADER, ALL
has $.vrules of VerticalRule = ALL;        #= Control the printing of horizontal rules between columns. Allowed values: FRAME, ALL

has $.int-format;                          #= Control the formatting of integer data.
has $.float-format;                        #= Control the formatting of floating point data.

has $.min-table-width of NonNeg;           #= Minimum desired table width, in characters
has $.max-table-width of NonNeg;           #= Maximum desired table width, in characters

has $.padding-width of NonNeg = 1;         #= Number of spaces on either side of column data (only used if left and right paddings aren't set).
has $.left-padding-width of NonNeg;        #= Number of spaces on left hand side of column data.
has $.right-padding-width of NonNeg;       #= Number of spaces on right hand side of column data.

has $.vertical-char             of Char = "│"; #= Single character string used to draw vertical lines.
has $.horizontal-char           of Char = "─"; #= Single character string used to draw horizontal lines.
has $.junction-char             of Char = "┼"; #= Single character string used to draw line junctions.
has $.left-junction-char        of Char = "├"; #= single character string used to draw left edge junctions
has $.right-junction-char       of Char = "┤"; #= single character string used to draw right edge junctions
has $.top-junction-char         of Char = "┬"; #= single character string used to draw top edge junctions (also under header)
has $.bottom-junction-char      of Char = "┴"; #= single character string used to draw bottom edge junctions
has $.bottom-left-corner-char   of Char = '└'; #= single character string used to draw the bottom left corner
has $.bottom-right-corner-char  of Char = '┘'; #= single character string used to draw the bottom right corner
has $.top-left-corner-char      of Char = '┌'; #= single character string used to draw the top left corner
has $.top-right-corner-char     of Char = '┐'; #= single character string used to draw the top right corner

has $.valign ;                             #= Default vertical alignment for each row (None, "t", "m" or "b").
has $.align;                               #= Default alignment for each row (None, "t", "m" or "b").

has $.print-empty of Bool = True;          #= Whether an empty table produce a header and frame (True) or just an empty string (False)

has $.sort-by of Str;                      #= Name of field to sort rows by.
has &.sort-key = sub ($x) { $x };          #= Sorting key function, applied to data points before sorting.
has $.reverse-sort of Bool = False;        #= Sort in descending (True) or ascending (False) order.
has $.old-sort-slice of Bool = False;      #= Slice rows before sorting in the "old style".
has $.wtf of Bool = False;
#
# Data
#

has @!rows;
has @!widths;
has $!min-width of NonNeg;
has $!max-width of NonNeg;
has %!min-width;
has %!max-width;
has $!hrule;
has $!format = False;
has $!markdown = False;

submethod TWEAK {
    self.int-format($!int-format);
    self.float-format($!float-format);

    self.align($!align);
    self.valign($!valign);
}

#
# Attribute management
#

=head1 Methods

=head2 Getter and Setter Methods

=begin para
B<NOTE>: These methods's names are the same as their respective attributes. To
set a specific attribute during the instantiation of a C<Prettier::Table> object,
use its method's name. For instance, to set  C<title>,
C«Prettier::Table.new(title => "Table's title")». Thus, all methods listed here
have an associated attribute that can be set during object construction.
=end para

method Str( --> Str ) {
    self.gist
}

method gist( --> Str ) {
    self.get-string
}


#| Return a list of field names.
multi method field-names( --> Array ) {
    @!field-names
}

#| Set a list of field names.
multi method field-names( @values --> Nil ) {
    validate-field-names :@values, :@!field-names, :@!rows;
    my @old-names;
    if @!field-names {
        @old-names = @!field-names;
    }
    @!field-names = @values;
    if $!align and @old-names {
        for (@old-names Z @values) -> ($old-name, $new-name) {
            $!align{$new-name} = $!align{$old-name}
        }
        for @old-names -> $old-name {
            $!align{$old-name}:delete if $!align{$old-name}:!exists;
        }
    }
    else {
        $!align{$_} = 'c' for @old-names;
    }

    if $!valign and @old-names {
        for (@old-names Z @values) -> ($old-name, $new-name) {
            $!valign{$new-name} = $!valign{$old-name}
        }
        for @old-names -> $old-name {
            $!align{$old-name}:delete if $!valign{$old-name}:!exists
        }

    }
    else {
        $!valign{$_} = 'c' for @old-names;
    }

}

#| Return how the alignment of fields is controlled.
multi method align( --> Hash ) {
    $!align
}

#| Set how the alignment of fields is controlled. Either an
#| alignment string (l, c, or r) or a hash of field-to-alignment pairs.
multi method align( $val --> Nil ) {
    my %align;
    if !$val.defined {
        $!align = %align;
    }
    else {
        if $val ~~ Str {
            validate-align $val;
            for @!field-names -> $field {
                %align{ $field } = $val;
            }

            $!align = %align;
        }
        elsif $val ~~ Hash {
            for $val.pairs -> $field-to-format {
                validate-align($field-to-format, @!field-names);
                %align{ $field-to-format.key } = $field-to-format.value
            }

            # Either $val was empty or none of its fields were in the field names.
            if %align.elems == 0 {
                %align{$_} = 'c' for @!field-names;
            }

            $!align = %align;
        }
        else {
            note
            qq:to/END/;
            align: Alignment be a string or a hash of field-to-format pairs.
            {$val} of type {$val.^name} was passed.
            END
        }
    }
}

#| Return how the vertical alignment of fields is controlled.
multi method valign( --> Hash ) {
    $!valign
}

#| Set how the vertical alignment of fields is controlled. Either an
#| alignment string (t, m, or b) or a hash of field-to-alignment pairs.
multi method valign( $val --> Nil ) {
    my %valign;
    if !$val.defined {
        $!valign = %valign;
    }
    else {
        if $val ~~ Str {
            validate-valign $val;
            for @!field-names -> $field {
                %valign{ $field } = $val;
            }

            $!align = %valign;
        }
        elsif $val ~~ Hash {
            for $val.pairs -> $field-to-format {
                validate-valign($field-to-format, @!field-names);
                %valign{ $field-to-format.key } = $field-to-format.value
            }

            # Either $val was empty or none of its fields were in the field names.
            if %valign.elems == 0 {
                %valign{$_} = 't' for @!field-names;
            }

            $!valign = %valign;
        }
        else {
            note
            qq:to/END/;
            valign: Alignment be a string or a hash of field-to-format pairs.
            {$val} of type {$val.^name} was passed.
            END
        }
    }
}

#| Return the maximum width of fields.
multi method max-width( --> NonNeg ) {
    %!max-width
}

#| Set the maximum width of fields.
multi method max-width( NonNeg $val --> Nil ) {
    if !$val.defined {
        %!max-width = %()
    }
    else {
        @!field-names.map(-> $field { %!max-width{ $field } = $val })
    }
}

#| Return the minimum width of fields.
multi method min-width( --> Hash ) {
    my @fields = $!header ?? @!field-names !! @!rows ?? @!rows[0] !! [];
    @fields .= flat;

    @fields.map(-> $name {
        $name => (self!str-block-width($name.Str), %!min-width{$name} // 0).max
    }).Hash;
}

#`{
@min_width.setter
def min_width(self, val):
    if val is None or (isinstance(val, dict) and len(val) is 0):
        self._min_width = {}
    else:
        self._validate_option("min_width", val)
        for field in self._field_names:
            self._min_width[field] = val
}

#| Set the minimum width of fields.
multi method min-width( $val --> Nil ) {
    my %min-width;
    if !$val.defined {
        # UNset the min-width of fields
        %!min-width = %min-width;
    }
    else {
        if $val ~~ Str {
            for @!field-names -> $field {
                %min-width{ $field } = $val;
            }
            %!min-width = %min-width;
        }
        elsif $val ~~ Hash {
            for $val.pairs -> $field-to-width {
                if $field-to-width.key ∈ @!field-names {
                    %min-width{ $field-to-width.key } = $field-to-width.value
                }
            }
            %!min-width = %min-width;
        }
        else {
            note qq:to/END/;
            min-width: Width must be an integer or a hash of field-to-width pairs.
            {$val} of type {$val.^name} was passed.
            END
        }
    }
}

#| Return the minimum desired table width, in characters.
multi method min-table-width( --> NonNeg ) {
    $!min-table-width
}

#| Set the minimum desired table width, in characters.
multi method min-table-width( NonNeg $val ) {
    $!min-table-width = $val
}

#| Return the maximum desired table width, in characters.
multi method max-table-width() {
    $!max-table-width
}

#| Set the minimum desired table width, in characters.
multi method max-table-width( NonNeg $val ) {
    $!max-table-width = $val
}

#| Return the list of field names to include in displays.
multi method fields( --> Array ) {
    @!fields
}

#| Return the list of field names to include in displays.
multi method fields( @values ) {
    validate-all-field-names :@values, :@!field-names;
    @!fields = @values
}

#| Return the table title (if existent).
multi method title( --> Str ) {
    $!title
}

#| Set the table title.
multi method title( Str $val ) {
    $!title = $val
}

#| Return the start index of the range of rows to print.
multi method start( --> NonNeg ) {
    $!start
}

#| Set the start index of the range of rows to print.
multi method start( NonNeg $val ) {
    $!start = $val
}

#| Return the end index of the range of rows to print.
multi method end {
    $!end
}

#| Set the end index of the range of rows to print.
multi method end( $val ) {
    $!end = $val
}

#| Return the name of field by which to sort rows.
multi method sort-by() {
    # TODO: Specify return type
   $!sort-by
}

#| Set the name of field by which to sort rows.
multi method sort-by(
    Str $val where ($val ∈  @!field-names || die "«{$val.gist}» isn't in the field names.")
) {
    # TODO: User should be able to specify a non-defined value (e.g., Nil)
    $!sort-by = $val
}

#| Return the direction of sorting, ascending (False)  vs descending (True).
multi method reverse-sort( --> Bool ) {
    $!reverse-sort
}

#| Set the direction of sorting (ascending (False) vs descending (True).
multi method reverse-sort( Bool $val --> Nil ) {
    $!reverse-sort = $val
}

#| Return the sorting key function, applied to data points before sorting.
multi method sort-key( --> Callable ) {
    &!sort-key
}

#| Set the sorting key function, applied to data points before sorting.
multi method sort-key( &val --> Nil ) {
    &!sort-key = &val
}

#| Return whether the table has a heading showing the field names.
multi method header( --> Bool ) {
    $!header
}

#| Set whether the table has a heading showing the field names.
multi method header( Bool $val --> Nil ) {
    $!header = $val
}

#| Return style to apply to field names in header ("cap", "title", "upper", or "lower").
multi method header-style( --> HeaderStyle ) {
    $!header-style
}

#| Set style to apply to field names in header ("cap", "title", "upper", or "lower").
multi method header-style( HeaderStyle $val ) {
    $!header-style = $val
}

#| Return whether a border is printed around table.
multi method border( --> Bool ) {
    $!border
}

#| Set whether a border is printed around table.
multi method border( Bool $val ) {
    $!border = $val
}

#| Return how horizontal rules are printed after rows.
multi method hrules( --> HorizontalRule ) {
    $!hrules
}

#| Set how horizontal rules are printed after rows. Allowed values: FRAME, ALL, HEADER, NONE
multi method hrules( HorizontalRule $val ) {
    $!hrules = $val
}

#| Return how vertical rules are printed between columns.
multi method vrules( --> VerticalRule ) {
    $!vrules
}

#| Set how vertical rules are printed between columns. Allowed values: FRAME, ALL, NONE
multi method vrules( VerticalRule $val ) {
    $!vrules = $val
}

#| Return how the integer data is formatted.
multi method int-format( ) {
    $!int-format;
}

#| Set how the integer data is formatted. The value can either be
#| a string or a hash of field-to-format pairs.
multi method int-format( $val --> Nil ) {
    my %int-format;
    if !$val.defined {
        $!int-format = %int-format;
    }
    else {
        if $val ~~ Str {
            for @!field-names -> $field {
                %int-format{ $field } = $val.ends-with('d') ?? $val !! $val ~ 'd';
            }

            $!int-format = %int-format;
        }
        elsif $val ~~ Hash {
            for $val.pairs -> $field-to-format {
                if $field-to-format.key ∈ @!field-names {
                    %int-format{ $field-to-format.key } =
                    $field-to-format.value.ends-with('d')
                    ?? $field-to-format.value
                    !! $field-to-format.value ~ 'd';
                }
            }

            $!int-format = %int-format;
        }
        else {
            note
            qq:to/END/;
            int-format: Format must be a string or a hash of field-to-format pairs.
            {$val} of type {$val.^name} was passed.
            END
        }
    }
}

#| Return how the integer data is formatted.
multi method float-format() {
    $!float-format;
}

#| Set how the integer data is formatted. The value can either be
#| a string or a hash of field-to-format pairs.
multi method float-format( $val --> Nil ) {
    sub validate-float-format( Str:D $str --> Bool ) {
        return True if $str.chars == 0;
        my $value = $str.split('f', :skip-empty).head;
        return False unless $value.contains('.');
        my @bits = $value.split('.');
        return False if @bits.elems > 3;
        return False without @bits[0] eq '' or @bits[0].Int;
        return False without @bits[1] eq '' or @bits[1].Int;
        return True;
    }

    my %float-format;
    if !$val.defined {
        $!float-format = %float-format;
    }
    else {
        if $val ~~ Str {
            my $format-is-valid = validate-float-format($val);
            unless $format-is-valid {
                die "Invalid directive ({$val}). It must be a float format string.";
            }

            for @!field-names -> $field {
                %float-format{ $field } = $val
            }

            $!float-format = %float-format;
        }
        elsif $val ~~ Hash {

            for $val.pairs -> $field-to-format {
                if $field-to-format.key ∈ @!field-names {
                    my $format-is-valid = validate-float-format($field-to-format.value);
                    unless $format-is-valid {
                        die "Invalid directive ({$field-to-format.value}). It must be a float format string.";
                    }

                    %float-format{ $field-to-format.key } = $field-to-format.value
                }
            }

            $!float-format = %float-format;
        }
        else {
            note
            qq:to/END/;
            float-format: Format must be a string or a hash of field-to-format pairs.
            {$val} of type {$val.^name} was passed.
            END
        }
    }
}


#| Return the number of empty spaces between a column's edge and its content.
multi method padding-width( --> NonNeg ) {
    $!padding-width
}

#| Set the number of empty spaces between a column's edge and its content.
multi method padding-width( NonNeg $val --> Nil ) {
    $!padding-width = $val
}

#| Return the number of empty spaces between a column's left edge and its content.
multi method left-padding-width( --> NonNeg ) {
    $!left-padding-width
}

#| Set the number of empty spaces between a column's left edge and its content.
multi method left-padding-width( NonNeg $val --> Nil ) {
    $!left-padding-width = $val
}

#| Return the number of empty spaces between a column's right edge and its content.
multi method right-padding-width( --> NonNeg ) {
    $!right-padding-width
}

#| Set the number of empty spaces between a column's right edge and its content.
multi method right-padding-width( NonNeg $val --> Nil ) {
    $!right-padding-width = $val
}

#| Return character used when printing table borders to draw vertical lines.
multi method vertical-char( --> Char ) {
    $!vertical-char
}

#| Set character used when printing table borders to draw vertical lines.
multi method vertical-char( Char $val --> Nil ) {
    $!vertical-char = $val
}

#| Return character used when printing table borders to draw horizontal lines.
multi method horizontal-char( --> Char ) {
    $!horizontal-char
}

#| Set character used when printing table borders to draw horizontal lines.
multi method horizontal-char( Char $val --> Nil ) {
    $!horizontal-char = $val
}

#| Return character used when printing table borders to draw mid-line junctions.
multi method junction-char( --> Char ) {
    $!junction-char
}

#| Set character used when printing table borders to draw mid-line junctions.
multi method junction-char( Char $val --> Nil ) {
    $!junction-char = $val
}

#| Return character used when printing table borders to draw left-edge line junctions.
multi method left-junction-char( --> Char ) {
    $!left-junction-char
}

#| Set character used when printing table borders to draw left-edge line junctions.
multi method left-junction-char( Char $val --> Nil ) {
    $!left-junction-char = $val
}

#| Return character used when printing table borders to draw right-edge line junctions.
multi method right-junction-char( --> Char ) {
    $!right-junction-char
}

#| Set character used when printing table borders to draw right-edge line junctions.
multi method right-junction-char( Char $val --> Nil ) {
    $!right-junction-char = $val
}

#| Return character used when printing table borders to draw top edge mid-line junctions.
multi method top-junction-char( --> Char ) {
    $!top-junction-char
}

#| Set character used when printing table borders to draw top edge mid-line junctions.
multi method top-junction-char( Char $val --> Nil ) {
    $!top-junction-char = $val
}

#| Return character used when printing table borders to draw bottom edge mid-line junctions.
multi method bottom-junction-char( --> Char ) {
    $!bottom-junction-char
}

#| Set character used when printing table borders to draw bottom edge mid-line junctions.
multi method bottom-junction-char( Char $val --> Nil ) {
    $!bottom-junction-char = $val
}

#| Return character used when printing table borders to draw bottem edge left corners.
multi method bottom-left-corner-char( --> Char ) {
    $!bottom-left-corner-char
}

#| Set character used when printing table borders to draw bottom edge left corners.
multi method bottom-left-corner-char( Char $val --> Nil ) {
    $!bottom-left-corner-char = $val
}

#| Return character used when printing table borders to draw bottom right corners.
multi method bottom-right-corner-char( --> Char ) {
    $!bottom-right-corner-char
}

#| Set character used when printing table borders to draw bottom right corners.
multi method bottom-right-corner-char( Char $val --> Nil ) {
    $!bottom-right-corner-char = $val
}

#| Return character used when printing table borders to draw top left corners.
multi method top-left-corner-char( --> Char ) {
    $!top-left-corner-char
}

#| Set character used when printing table borders to top left corners.
multi method top-left-corner-char( Char $val --> Nil ) {
    $!top-left-corner-char = $val
}

#| Return character used when printing table borders to top right corners.
multi method top-right-corner-char( --> Char ) {
    $!top-right-corner-char
}

#| Set character used when printing table borders to draw top right corners.
multi method top-right-corner-char( Char $val --> Nil ) {
    $!top-right-corner-char = $val
}

#| Return whether or not HTML tables are formatted to match styling options.
multi method format( --> Bool ) {
    $!format
}

#| Set whether or not HTML tables are formatted to match styling options.
multi method format( Bool $val --> Nil ) {
    $!format = $val
}

#| Return whether or not empty tables produce a header and frame or just an empty string.
multi method print-empty( --> Bool ) {
    $!print-empty
}

#| Set whether or not empty tables produce a header and frame or just an empty string.
multi method print-empty( Bool $val --> Nil ) {
    $!print-empty = $val
}

#| Return whether to slice rows before sorting in the "old style".
multi method old-sort-slice( --> Bool ) {
    $!old-sort-slice
}

#| Return whether to slice rows before sorting in the "old style".
multi method old-sort-slice( Bool $val --> Nil ) {
    $!old-sort-slice = $val
}

#
# Preset style logic
#

=head2 Style of Table

#| Set the style to be used for the table. Allowed values:
#| DEFAULT: Show header and border, hrules and vrules are FRAME and ALL
#| respectively, paddings are 1, ASCII Box Drawing characters used for borders.
#| MSWORD-FRIENDLY: Show header and border, hrules is NONE, paddings are 1, and
#| vert. char is |
#| MARKDOWN: GitHub Flavored Markdown table. - Removes title, only hrule below
#| column headers, paddings are 1, and vert. char is |
#| PLAIN-COLUMNS: Show header and hide border, hrules is NONE, padding is 1,
#| left padding is 0, and right padding is 8
#| RANDOM: random style
multi method set-style( TableStyle $style --> Nil ) {
    given $style {
        when MSWORD-FRIENDLY { self!set-msword-style()   }
        when MARKDOWN        { self!set-markdown-style() }
        when PLAIN-COLUMNS   { self!set-columns-style()  }
        when RANDOM          { self!set-random-style()   }
        when DEFAULT         { self!set-default-style()  }
        default              { self!set-default-style()  }
    }
}
multi method set-style( Str $string_style --> Nil ) {
    my $style = TableStyle::{$string_style};
    die "Unknown style $string_style" unless $style.defined;
    self.set-style($style);
}

method !set-default-style( --> Nil ) {
    $!header                = True;
    $!border                = True;
    $!hrules                = FRAME;
    $!vrules                = ALL;
    $!padding-width         = 1;
    $!left-padding-width    = 1;
    $!right-padding-width   = 1;
    $!vertical-char         = "│"; #= Single character string used to draw vertical lines.
    $!horizontal-char       = "─"; #= Single character string used to draw horizontal lines.
    $!junction-char         = "┼"; #= Single character string used to draw line junctions.
    $!left-junction-char    = "├";
    $!right-junction-char   = "┤";
    $!top-junction-char     = "┬";
    $!bottom-junction-char  = "┴";
}

method !set-msword-style( --> Nil ) {
    $!header                = True;
    $!border                = True;
    $!hrules                = NONE;
    $!padding-width         = 1;
    $!left-padding-width    = 1;
    $!right-padding-width   = 1;
    $!vertical-char         = '|';
    $!top-left-corner-char  = '+';
    $!top-right-corner-char = '+';
    $!horizontal-char       = '-';
}
#| modifies border characters to produce markdown output
method !set-markdown-style( --> Nil ){
    $!markdown = True;
    $!title = Nil;
    $!hrules = HEADER;
    $!vrules = ALL;
    $!vertical-char = '|';
    $!horizontal-char= '-';
    $!junction-char = '|';
    $!left-junction-char = '|';
    $!right-junction-char = '|';
    $!top-junction-char = Nil;
    $!bottom-junction-char = Nil;
    # NOTE: alignment is handled via the heading line.
    # colons indicate alignment
    #
    # |----| => no alignment specified
    # |:---| => left aligned
    # |---:| => right aligned
    # |:--:| => center aligned
    #
    # NOTE: there is no colspan functionality
    # so title will look like crap
    # TODO: Make title's optional
}


method !set-columns-style( --> Nil ) {
    $!header = True;
    $!border = False;
    $!padding-width = 1;
    $!left-padding-width = 0;
    $!right-padding-width = 8;
}

method !set-random-style( --> Nil ) {
    $!header = Bool.pick;
    $!border = Bool.pick;
    $!hrules = (ALL, FRAME, HEADER, NONE).pick;
    $!vrules = (ALL, FRAME, NONE).pick;
    $!left-padding-width  = (^6).pick;
    $!right-padding-width = (^6).pick;
    $!vertical-char   = '~!@#$%^&*()_+|-=\{}[];\':",./;<>?'.split('', :skip-empty).pick;
    $!horizontal-char = '~!@#$%^&*()_+|-=\{}[];\':",./;<>?'.split('', :skip-empty).pick;
    $!junction-char   = '~!@#$%^&*()_+|-=\{}[];\':",./;<>?'.split('', :skip-empty).pick;
}

#
# Data input methods
#

=head2 Data Input Methods

#| Add a row to the table.
method add-row(
    @row #= Row of data, should be a list with as many elements as the table has fields.
    --> Nil
) {

    if @!field-names && @row.elems != @!field-names {
        die "Row has incorrect number of values, (actual) " ~
        "{@row.elems} != {@!field-names.elems}%d (expected)";
    }

    # no field names so let's create our own.
    unless @!field-names {
        my $n := @row.elems;
        @!field-names = ('Field ' xx $n) Z~ (1..$n);
    }

    @!rows.push(@row);
}

#| Delete a row from the table.
method del-row(
    Int $row-index #= Index of the row to delete (0-based index).
    --> Nil
) {
    if $row-index > @!rows.elems - 1 {
        X::OutOfRange.new(:what<Row>, :got($row-index), :range(0..^@!rows.elems)).throw
    }

    @!rows[$row-index]:delete;
}

#| Add a column to the table.
method add-column(
    Str $fieldname,       #= Name of the field to contain the new column of data.
        @column,          #= Column of data, should be a list with as many elements as the table has rows.
    Align $align = 'c',   #= Desired alignment for this column - "l" (left), "c" (center), and "r" (right).
    VAlign $valign = 'm', #= Desired vertical alignment for new columns - "t" (top), "m" (middle), and "b" (bottom).
    --> Nil
) {
    unless @!rows.elems ∈ (0, @column.elems) {
        die "Column length {@column.elems} does not match number of rows {@!rows.elems}!"
    }

    @!field-names.push($fieldname);
    $!align{ $fieldname } = $align;
    $!valign{ $fieldname } = $valign;

    for 0 ..^ @column.elems -> $i {
        if @!rows < $i + 1 {
            @!rows.push([])
        }
        @!rows[$i].push(@column[$i]);

    }
}

#| Delete all rows from the table but keep the current field names.
method clear-rows( --> Nil) {
    @!rows = Empty;
}

#| Delete all rows and field names from the table, maintaining nothing but styling options.
method clear( --> Nil ) {
    @!rows = Empty;
    @!field-names = Empty;
    @!widths = Empty;
}

#
# Plain text string methods
#

=head2 Plain Text String methods

#| Return string representation of table in current state.
method get-string(
    Str            :$title                     = Str,            #= See method title
    NonNeg         :$start                     = NonNeg,         #= See method start
    NonNeg         :$end                       = NonNeg,         #= See method end
                   :@fields,                                     #= See method fields
    Bool           :$header                    = Bool,           #= See method header
    Bool           :$border                    = Bool,           #= See method border
    HorizontalRule :$hrules                    = HorizontalRule, #= See method hrules
    VerticalRule   :$vrules                    = VerticalRule,   #= See method vrules
    Str            :$int-format                = Str,            #= See method int-format
    Str            :$float-format              = Str,            #= See method float-format
    NonNeg         :$padding-width             = NonNeg,         #= See method padding-width
    NonNeg         :$left-padding-width        = NonNeg,         #= See method left-padding-width
    NonNeg         :$right-padding-width       = NonNeg,         #= See method right-padding-width
    Char           :$vertical-char             = Char,           #= See method vertical-char
    Char           :$horizontal-char           = Char,           #= See method horizontal-char
    Char           :$junction-char             = Char,           #= See method junction-char
    Char           :$left-junction-char        = Char,           #= See method junction-char
    Char           :$right-junction-char       = Char,           #= See method right-junction-char
    Char           :$top-junction-char         = Char,           #= See method top-junction-char
    Char           :$bottom-junction-char      = Char,           #= See method bottom-junction-char
    Char           :$bottom-left-corner-char   = Char,           #= See method bottom-left-corner-char
    Char           :$bottom-right-corner-char  = Char,           #= See method bottom-right-corner-char
    Char           :$top-left-corner-char      = Char,           #= See method top-left-corner-char
    Char           :$top-right-corner-char     = Char,           #= See method top-right-corner-char
    Str            :$sort-by                   = Str,            #= See method sort-by
                   :&sort-key,                                   #= See method sort-key
    Bool           :$reverse-sort              = Bool,           #= See method reverse-sort
    Bool           :$old-sort-slice            = Bool,           #= see method old-sort-slice
    Bool           :$print-empty               = Bool,           #= See method print-empty
    --> Str
) {
    my @lines = self!prepare-lines:
        :$title,
        :$start,
        :$end,
        :@fields,
        :$header,
        :$border,
        :$hrules,
        :$vrules,
        :$int-format,
        :$float-format,
        :$padding-width,
        :$left-padding-width,
        :$right-padding-width,
        :$vertical-char,
        :$horizontal-char,
        :$junction-char,
        :$sort-by,
        :&sort-key,
        :$reverse-sort,
        :$old-sort-slice,
        :$print-empty,
    ;

    return @lines.join("\n");
}

method !prepare-lines( *%_ ) {
    =begin comment
    A Prettier::Table's attributes are set by the outside world either at
    object's construction or using their respective setter methods.
    The get-string method's goal is to return a table's string
    representation in its current state with whatever information updated
    via its parameters. If Prettier::Table relied on passing the table's
    current state by parameters the following wouldn't be needed. Instead,
    the table's current state is kept via the table's attributes. So we
    "record" with a via of metaprogramming the table's state right before the
    get-string's parameters (if defined) are applied and then set the table back
    right before prepare-lines returns.
    =end comment
    my %original;
    for %_.grep(*.value.defined).Hash.keys -> $method-name {
        my $getter = self.^find_method($method-name).candidates.first(*.arity == 1);

        # FIX: Doing this because otherwise the error:
        # Invocant of method 'end' must be a type object of type 'Any',
        # not an object instance of type 'Prettier::Table'.  Did you forget a 'multi'?
        %original{$method-name} = $method-name eq 'end' ?? self.end !! self.$getter;

        my $setter = self.^find_method($method-name).candidates.first(*.arity == 2);

        # FIX: Doing this because otherwise the error:
        # Invocant of method 'end' must be a type object of type 'Any',
        # not an object instance of type 'Prettier::Table'.  Did you forget a 'multi'?
        $method-name eq 'end' ?? self.end(%_{$method-name}) !! self.$setter(%_{$method-name});
    }

    if self.row-count() == 0 and (!$!print-empty or !$!border) {
        return [];
    }

    # Get the rows we need to print, taking into account slicing, sorting, etc.
    my @rows = self!get-rows;

    my @formatted-rows = self!format-rows(@rows);

    # Compute column widths
    self!compute-widths(@formatted-rows);

    my @lines;

    # Add title
    @lines.push(self!stringify-title($!title)) if $!title.defined and ! $!markdown;
    # Add header or top of border

    if $!header and $!title.defined {
        @lines.append(self!stringify-header(row=>'header-middle').split(/\r\n|\n/));
    } elsif $!header {
        @lines.append(self!stringify-header(row=>'header-top').split(/\r\n|\n/));
    } elsif $!border and $!hrules ∈ (ALL, FRAME) {
        @lines.push(self!stringify-hrule(row => 'top'));
    }

    # Add rows of content (after title and headers)
    loop (my $i = 0; $i < @formatted-rows.elems; $i++) {

        if $i < @formatted-rows.elems - 1 {
            my @stringified-lines = self!stringify-row(@formatted-rows[$i].Array, row-position => 'middle');
            @lines.push(@stringified-lines);
        } else {
            my @stringified-lines = self!stringify-row(@formatted-rows[$i].Array, row-position => 'bottom');
            @lines.push(@stringified-lines);
        }
    }
    # Add bottom border
    if $!border and $!hrules ~~ FRAME {
        @lines.push(self!stringify-hrule(row => 'bottom'));
    }

    =begin comment
    Setting the table's state back to how it was before the latest get-string call.
    Here we're getting the Prettier::Table setter methods related to prepare-lines's
    parameter list and setting to their previous values (if any).
    =end comment
    for %original.keys -> $method-name {
        my $setter = self.^find_method($method-name).candidates.first(*.arity == 2);
        self.$setter(%original{$method-name}) if %original{$method-name}.defined;
    }

    return @lines;
}

method !stringify-hrule( Str :$row = 'middle', Positional :$alignments?) {
    return "" unless $!border;
    # FIXME won't work if no field names
    my @aligns = $alignments // \
                  ("c" x @!field-names.elems).split("",:skip-empty);

    my ($lpad, $rpad) = self!get-padding-widths;
    my @bits;

    if ! $!markdown and $!vrules ∈  (ALL, FRAME).one {
        @bits.push($!left-junction-char)       if $row eq 'middle' or $row eq 'header-bottom' or $row eq 'header-middle';
        @bits.push($!top-left-corner-char)     if $row eq 'top' or $row eq 'header-top' ;
        @bits.push($!bottom-left-corner-char)  if $row eq 'bottom';
    } elsif $!markdown {
        @bits.push($!left-junction-char) if $row eq 'middle' or $row eq 'header-bottom'
    }
    else {
        @bits.push($!horizontal-char)
    }

    unless @!field-names {
        # FIXME this can't be right with new complex junction possibilities
        @bits.push($!junction-char);
        return @bits.join
    }

    for (@!field-names Z @!widths Z @aligns) -> ($field, $width, $align) {
 if @!fields and $field ∉  @!fields {
} else {
 }

        next if @!fields and $field ∉  @!fields;
        my $padded_width = $width + $lpad + $rpad;

        if $!markdown {
            given $align {
                when 'l' {
                    @bits.push(':' ~ ( $!horizontal-char x ($padded_width - 1)) );
                }
                when 'r' {
                    @bits.push( ($!horizontal-char x ($padded_width - 1)) ~ ':' );
                }
                default {
                    @bits.push($!horizontal-char x $padded_width);
                }
            }

        } else {
            @bits.push($!horizontal-char x $padded_width);
        }


        if $!vrules {
            @bits.push($!junction-char)         if $row eq 'middle' or $row eq 'header-bottom';
            @bits.push($!top-junction-char)     if $row eq 'top'    or $row eq 'header-top' or $row eq 'header-middle';
            @bits.push($!bottom-junction-char)  if $row eq 'bottom';
        }
        else {
            @bits.push($!horizontal-char)
        }
    }
    if $!vrules {
        # replace the last junction-char with whatever's appropriate
        @bits[*-1] = $!right-junction-char       if $row eq 'middle' or $row eq 'header-bottom' or $row eq 'header-middle';
        @bits[*-1] = $!bottom-right-corner-char  if $row eq 'bottom';
        @bits[*-1] = $!top-right-corner-char     if $row eq 'top' or $row eq 'header-top';
    }

    if $!vrules ~~ FRAME { # markdown is ALL
        @bits.pop;
        @bits.push($!right-junction-char)       if $row eq 'middle' or $row eq 'header-middle' or $row eq 'header-bottom';
        @bits.push($!top-right-corner-char)     if $row eq 'top' or $row eq 'header-top' ;
        @bits.push($!bottom-right-corner-char)  if $row eq 'bottom';
    }

    @bits.join('');
}

method !stringify-title( $title is copy --> Str ) {
    my @lines;
    my ($lpad, $rpad) = self!get-padding-widths;
    if $!border {
        if $!vrules == ALL {
            $!vrules = FRAME;
            @lines.push(self!stringify-hrule(row => 'header-top'));
            $!vrules = ALL;
        }
        elsif $!vrules == FRAME {
            @lines.push(self!stringify-hrule(row => 'header-top'));
        }
    }
    my @bits;
    my $endpoint = $!vrules == (ALL, FRAME).one ?? $!vertical-char !! " ";
    @bits.push($endpoint);
    $title = (' ' x $lpad, $title, ' ' x $rpad).join;
    my $hrule = self!stringify-hrule(row => 'header-bottom');

    @bits.push(self!justify($title, $hrule.chars - 2, 'c'));
    @bits.push($endpoint);
    @lines.push(@bits.join);
    return @lines.join("\n");
}

method !stringify-header(Str :$row = 'header-top') {
    my @bits;
    my ($lpad, $rpad) = self!get-padding-widths();

    if $!border {
        if $!hrules ∈ (ALL, FRAME).one {
            @bits.push(self!stringify-hrule(row=>$row));
            @bits.push("\n")
        }
        if $!vrules ∈ (ALL, FRAME).one {
            @bits.push($!vertical-char)
        }
        else {
            @bits.append(" ")
        }
    }

    # for tables with no data or field names
    unless @!field-names {
        if $!vrules ∈ (ALL, FRAME).one {
            @bits.push($!vertical-char)
        }
        else {
            @bits.push(" ")
        }
    }

    my @column_alignments = [];
    for (@!field-names Z @!widths) -> ($field, $width) {
        if @!fields and $field ∉  @!fields {
            next
        }
        my $fieldname = do given $!header-style {
            when 'cap'   { $field.tc }
            when 'title' { $field.tc }
            when 'upper' { $field.uc }
            when 'lower' { $field.lc }
            default      { $field    }
        }

        @bits.push(" " x $lpad ~ self!justify($fieldname, $width, $!align{$field} // 'c') ~ " " x $rpad);
        @column_alignments.push($!align{$field} // 'c');
        if $!border {
            if $!vrules ~~ ALL {
                @bits.push($!vertical-char)
            }
            else {
                @bits.push(" ")
            }
        }
    }

    # if vrules is FRAME, then we just appended a space at the end of the last
    # field, when we really wanted a vertical character
    if $!border and $!vrules ~~ FRAME {
        @bits.pop;
        @bits.push($!vertical-char);
    }

    if $!border and $!hrules !~~ NONE {
        @bits.push("\n");
        my $hrule-row = ($row eq 'header-middle' or $row eq 'header-top') ?? 'header-bottom' !! $row;
        @bits.push(self!stringify-hrule(row=>$hrule-row, alignments => @column_alignments));
    }
    return @bits.join('')
}

method !stringify-row( @row, Str :$row-position = 'middle' --> Str ) {
    for 0..^@row.elems Z @!field-names Z @row Z @!widths -> ($index, $field, $value, $width) {
        my @lines = $value.split(/\r\n|\n/);
        my @new-lines;
        for @lines <-> $line {
            if self!str-block-width($line) > $width {
                $line = wrap-text($line, :$width, :hard-wrap);
            }
            @new-lines.push($line)
        }
        @lines = @new-lines;
        @row[$index] = @lines.join("\n");
    }

    my $row-height = 0;
    for @row -> $c {
        my $h = self!get-size($c)<height>;
        $row-height = $h if $h > $row-height;
    }

    my @bits;
    my ($lpad, $rpad) = self!get-padding-widths;
    for ^$row-height -> $y {
        @bits.push([]);
        if $!border {
            my $char := $!vrules ∈  (ALL, FRAME) ?? self.vertical-char !! " ";
            @bits[$y].push($char);
        }
    }

    for @!field-names.flat Z @row.flat Z @!widths.flat -> ($field, $value, $width) {
        my $valign = $!valign{$field};
        my @lines = $value.split(/\r\n|\n/);
        my $height-diff = $row-height - @lines.elems;
        if $height-diff {
            given $valign {
                when "m" { @lines = |("" xx $height-diff div 2), |@lines, |("" xx ($height-diff - $height-diff div 2)) }
                when "d" { @lines = |("" xx $height-diff), |@lines }
                default  { @lines = |@lines, |("" xx $height-diff) }
            }
        }

        my $y = 0;
        for @lines -> $l {
            next if @!fields and $field ∉ @!fields;
            @bits[$y].push(" " x $lpad ~ self!justify($l, $width, $!align{$field} // 'c') ~ " " x $rpad);
            if $!border {
                my $char := $!vrules ~~ ALL ?? self.vertical-char !! " ";
                @bits[$y].push($char);
            }
            $y += 1;
        }
    }

    # if vrules is FRAME, then we just appended a space at the end
    # of the last field, when we really want a vertical character.
    for ^$row-height -> $y {
        if $!border and $!vrules ~~ FRAME {
            @bits.pop;
            @bits[$y].push(self.vertical-char)
        }
    }

    if $!border and $!hrules ~~ ALL {
        @bits[$row-height - 1].push("\n");
        @bits[$row-height - 1].push(self!stringify-hrule(row => $row-position))
    }

    for ^$row-height -> $y {
        @bits[$y] = @bits[$y].map({ $_ !=== Any ?? $_ !! '' }).join
    }
    return @bits.join("\n")
}

method !justify( Str $text, Int $width, Str $align --> Str ) {

    my $excess = $width - self!str-block-width($text);

    sub center-align( $text, $excess ) {
        if $excess mod 2 {
            if self!str-block-width($text) mod 2 {
                return (' ' x ($excess div 2), $text, ' ' x ($excess div 2 + 1)).join
            }
            else {
                return (' ' x ($excess div 2 + 1), $text, ' ' x ($excess div 2)).join
            }
        }
        else {
            return (' ' x ($excess div 2), $text, ' ' x ($excess div 2)).join
        }
    }

    return do given $align {
        when 'l' { ($text, ' ' x $excess).join  }
        when 'r' { (' ' x $excess, $text).join  }
        default  { center-align($text, $excess) }
    }

}

method !get-size( $text --> Hash ) {
    my @lines = $text.split(/\r\n|\n/);
    my $height = @lines.elems;
    my $width = @lines.map({ self!str-block-width($^line) }).max;
    return %( :$width, :$height );
}

method !str-block-width( Str $text ) {
    return $text.chars
}

#
# Miscellaneous methods
#

=head2 Miscellaneous Methods

#| Return the number of rows.
method row-count( --> Int ) {
    @!rows.elems
}

#| Return the number of columns.
method col-count( --> Int ) {
    return @!field-names.elems if @!field-names;
    return @!rows[0].elems if @!rows;
    return 0;
}

method elems( ::?CLASS:D: ) {
    @!rows.elems
}

#| Return a sliced-off new Prettier::Table. The indices must between 0 and the
#| table's number of rows (exclusive). Alternatively, the postcircumfix operator
#| [] can be used.
method slice( *@indices --> Prettier::Table ) {
    # all indices must be within the valid range.
    unless @indices.all ∈ 0..^@!rows.elems {
        X::OutOfRange.new(
            what => "Indices",
            got => @indices.join(', '),
            range => "0..{@!rows.elems - 1}"
        ).throw;
    }

    my $new-table = Prettier::Table.new;
    $new-table.field-names(self.field-names);

    # copy self's attribute values into the sliced table.
    # This is a "here be dragons" situation.
    for self.^attributes(:local) -> $attr {
        # @indices dictates which rows to include so skip setting this attribute.
        next if $attr eq '@!rows';
        $attr.set_value($new-table, $attr.get_value(self))
    }

    # get them rows
    for @!rows[@indices] -> $row {
        $new-table.add-row($row);
    }

    return $new-table;
}

# COMMENTED OUT because of rakudo bug
# https://github.com/rakudo/rakudo/issues/5079
#
# Getting this to work was tricky.
# See https://stackoverflow.com/a/60061569
# multi sub postcircumfix:<[ ]> ( Prettier::Table $n, $index, *@indices ) is default is export {
#     die("death in postcircumfix");
#     #$n.slice(|$index, |@indices)
# }

#
# Miscellaneous private methods
#

method !compute-table-width( --> Int ) {
    my Int $table-width = $!vrules ~~ (FRAME, ALL).one ?? 2 !! 0;
    my Int $per-column-padding = self!get-padding-widths.sum;
    for @!field-names.kv -> $index, $fieldname {
        if !@!fields or (@!fields and $fieldname ∈  @!fields) {
            $table-width += @!widths[$index] + $per-column-padding
        }
    }
    return $table-width;
}

method !compute-widths( @rows --> Nil ) {
    my @widths = $!header
        ?? @!field-names.map(-> $field { self!get-size($field)<width> })
        !! 0 xx @!field-names.elems;

    for @rows -> $row {
        for $row.flat.kv -> $index, $value {
            my $fieldname = @!field-names[$index];
            @widths[$index] = %!max-width{ $fieldname }:exists
            ?? max(@widths[$index], min(self!get-size($value)<width>, %!max-width{$fieldname}))
            !! max(@widths[$index], self!get-size($value)<width>);

            # %!min-width must be set somewhere.
            if self.min-width{$fieldname}:exists {
                @widths[$index] = max(@widths[$index], self.min-width{$fieldname});
            }
        }
    }

    @!widths = @widths;

    if $!max-table-width {
        my $table-width = self!compute-table-width;
        if $table-width > $!max-table-width {
            # get hash with minimum widths for fields
            my %min-width = self.min-width;
            # space for vrules
            my $nonshrinkable = $!vrules ∈ (FRAME, ALL) ?? 2 !! 0;
            # space for vrules between columns
            $nonshrinkable += @!field-names.elems - 1;
            # space for padding in each column
            my $per-col-padding = self!get-padding-widths.sum;
            $nonshrinkable += @widths.elems * $per-col-padding;
            # min space for each column
            $nonshrinkable += %min-width.values.sum;
            my $scale = ($!max-table-width - $nonshrinkable) / ($table-width - $nonshrinkable);
            sub calculate-new-with($fieldname, $old-width) {
                my $width = %min-width{$fieldname};
                # scale according to recalculated table width
                my $scaled-part = (($old-width - $width) * $scale).floor.Int;
                return (1, $width + $scaled-part).max
            }

            # TODO: More idiomatic way of doing this?
            @widths = (@!field-names Z @widths).map({calculate-new-with(|$_)});
            @!widths = @widths;
        }
    }

    # are we under min-table-width or title's width?
    if $!min-table-width or $!title {
        my $title-width = 0;
        if $!title {
            $title-width = $!title.chars + self!get-padding-widths.sum;
            $title-width += 2 if $!vrules ∈ (FRAME, ALL);
        }

        my $min-table-width = $!min-table-width // 0;
        my $min-width = ($title-width, $min-table-width).max;
        my $table-width = self!compute-table-width;
        if $table-width < $min-width {
            # grow widths proportionally
            my $scale = 1.0 * $min-width / $table-width;
            @widths = @widths.map({ ($^w * $scale).ceiling });
            @!widths = @widths;
        }
    }
}

method !get-padding-widths( --> List ) {
    my $lpad = $!left-padding-width.defined ?? $!left-padding-width  !! $!padding-width;
    my $rpad = $!right-padding-width.defined ?? $!right-padding-width !! $!padding-width;
    return $lpad, $rpad;
}

method !get-rows( --> Array ) {
    my @rows = $!old-sort-slice ?? @!rows[ $!start ..^ $!end ] !! @!rows;
    @rows = @rows.map(*.Array);

    with $!sort-by {
        my $sort-index = @!field-names.grep({ $_ eq $!sort-by }, :k).first;

        # add field to sort by at front of each row.
        @rows = @rows.map(-> $row { $row.unshift($row[$sort-index]) });

        # sort rows.
        @rows = @rows.sort(&!sort-key);
        @rows = @rows.reverse if $!reverse-sort;

        @rows = @rows.map(*[1..*].Array);
    }

    unless $!old-sort-slice {
        @rows = @rows[ $!start ..^ $!end ];
    }

    return @rows;
}

method !format-value( $field, $value is copy ) {
    if $value.isa(Int) and $!int-format{$field}:exists {
        my $format = '%' ~ $!int-format{$field};
        $value = sprintf $format, $value;
    }
    elsif $value.isa(Rat) and $!float-format{$field}:exists {
        my $format = '%' ~ $!float-format{$field};
        $value = sprintf $format, $value;
    }
    elsif $value.isa(Num) and $!float-format{$field}:exists {
        my $format = '%' ~ $!float-format{$field};
        $value = sprintf $format, $value;
    }
    return $value;
}

method !format-row( @row --> List ) {
    (@!field-names Z @row).map(-> ($field, $value) { self!format-value($field, $value) }).list
}

method !format-rows( @rows --> List ) {
    @rows.map(-> $row { self!format-row($row) }).list
}

#
# Documentation
#

=begin pod

=head1 Name

C<Prettier::Table>, a simple Raku module to make it quick and easy to represent
tabular data in visually appealing ASCII tables.

By default it will generate tables using ASCII Box Drawing characters as show in
the examples below. But you can also generate L<GFM Markdown tables|https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/organizing-information-with-tables>, and MS Word Friendly tables by calling C<$my_table.set-style('MARKDOWN')> or C<$my_table.set-style('MSWORD-FRIENDLY')> Check out C<demo.raku> to see this in action.


This is a fork of L<Luis F Uceta's Prettier::Table|https://gitlab.com/uzluisf/raku-pretty-table> which is itself a port of
the L<Kane Blueriver's PTable library for Python|https://github.com/kxxoling/PTable>.

=head1 Synopsis

B<Example 1>:

=begin code
use Prettier::Table;

my $table = Prettier::Table.new:
    title => "Australian Cities",
    field-names => ["City name", "Area", "Population", "Annual Rainfall"],
    sort-by => 'Area',
    align => %('City name' => 'l'),
;

given $table {
    .add-row: ["Adelaide",  1295,  1158259,  600.5 ];
    .add-row: ["Brisbane",  5905,  1857594,  1146.4];
    .add-row: ["Darwin",    112,   120900,   1714.7];
    .add-row: ["Hobart",    1357,  205556,   619.5 ];
    .add-row: ["Sydney",    2058,  4336374,  1214.8];
    .add-row: ["Melbourne", 1566,  3806092,  646.9 ];
    .add-row: ["Perth",     5386,  1554769,  869.4 ];
}

say $table;
=end code

Output:

<img alt="actual rendering" src="https://github.com/masukomi/Prettier-Table/blob/images/images/australian_cities.png?raw=true" />

(GitHub displays the raw text incorrectly)


=begin code

    ┌─────────────────────────────────────────────────┐
    │                Australian Cities                │
    ├───────────┬──────┬────────────┬─────────────────┤
    │ City name │ Area │ Population │ Annual Rainfall │
    ├───────────┼──────┼────────────┼─────────────────┤
    │ Darwin    │ 112  │   120900   │      1714.7     │
    │ Adelaide  │ 1295 │  1158259   │      600.5      │
    │ Hobart    │ 1357 │   205556   │      619.5      │
    │ Melbourne │ 1566 │  3806092   │      646.9      │
    │ Sydney    │ 2058 │  4336374   │      1214.8     │
    │ Perth     │ 5386 │  1554769   │      869.4      │
    │ Brisbane  │ 5905 │  1857594   │      1146.4     │
    └───────────┴──────┴────────────┴─────────────────┘
=end code


B<Example 2>:

=begin code
use Prettier::Table;

my $table = Prettier::Table.new;

given $table {
    .add-column('Planet', ['Earth', 'Mercury', 'Venus', 'Mars', 'Jupiter', 'Saturn', 'Uranus', 'Neptune']);
    .add-column('Position', [3, 1, 2, 4, 5, 6, 7, 8])
    .add-column('Known Satellites', [1, 0, 0, 2, 79, 82, 27, 14]);
    .add-column('Orbital period (days)', [365.256, 87.969, 224.701, 686.971, 4332.59, 10_759.22, 30_688.5, 60_182.0]);
    .add-column('Surface gravity (m/s)', [9.806, 3.7, 8.87, 3.721, 24.79, 10.44, 8.69, 11.15]);
}

$table.title('Planets in the Solar System');
$table.align(%(:Planet<l>));
$table.float-format(%('Orbital period (days)' => '-10.3f', 'Surface gravity (m/s)' => '-5.3f'));
$table.sort-by('Position');
# If you wish to change any of the characters used in the border
# you could do something like this.
# $table.junction-char('*');

put $table;
=end code

Output:

<img alt="actual rendering" src="https://github.com/masukomi/Prettier-Table/blob/images/images/planets_of_the_solar_system.png?raw=true" />

(GitHub displays the raw text incorrectly)
=begin code

    ┌────────────────────────────────────────────────────────────────────┐
    │                    Planets in the Solar System                     │
    ├─────────┬──────────┬───────────────────────┬───────────────────────┤
    │  Planet │ Position │ Orbital period (days) │ Surface gravity (m/s) │
    ├─────────┼──────────┼───────────────────────┼───────────────────────┤
    │  Earth  │    3     │        365.256        │         9.806         │
    │ Mercury │    1     │         87.969        │          3.7          │
    │  Venus  │    2     │        224.701        │          8.87         │
    │   Mars  │    4     │        686.971        │         3.721         │
    │ Jupiter │    5     │        4332.59        │         24.79         │
    │  Saturn │    6     │        10759.22       │         10.44         │
    │  Uranus │    7     │        30688.5        │          8.69         │
    │ Neptune │    8     │         60182         │         11.15         │
    └─────────┴──────────┴───────────────────────┴───────────────────────┘
=end code

=head1 Installation

Using zef:

=code zef install Prettier::Table

From source:

=begin code
$ git clone
$ cd raku-pretty-table
$ zef install .
=end code

=head1 Quickstart

C<Prettier::Table> supports two kinds of usage:

=head2 As a module

=begin code
use Prettier::Table;
my $x = Prettier::Table.new;
=end code

Check out the attributes in C<Prettier::Table> to see the full list of things that can be set / configured. Most notably the
C<*-char> attributes, used to control the look of the border.
Additionally, the named parameters in the C<get-string> method.

=head2 AUTHORS

=item L<Luis F Uceta's Prettier::Table|https://gitlab.com/uzluisf/raku-pretty-table>
=item L<masukomi|https://masukomi.org>

=head2 LICENSE
=para
MIT. See LICENSE file.

=end pod

#
# Pod related
#

# This subroutine is adapted to the way this module's Pod is structured so
# I wouldn't bet on its usefulness elsewhere. The reason I decided to do this is:
# 1) I didn't want all the documentation in the named pod at the top of the module
# 2) Even if I placed the named pod at the bottom, the way a module's Pod is
# parsed by default meant that declarator blocks wouldn't follow after the named pod.
# 3) Pod::EOD (https://github.com/hoelzro/p6-pod-eod) allows you to move the
# declarator blocks to the end of the module, however it leaves the headers
# and paragraphs introducing those code sections behind.
sub move-declarations-to-end($pod) {
     # get the named pod
     my $named-pod = $pod.cache
        .grep(* ~~ Pod::Block::Named && *.?name !=:= Nil)
        .grep(*.name eq 'pod').Array;

     # A code section is just a heading and paragraph followed by declarator blocks.
     my @code-sections = $pod.cache.grep( -> $part {
             $part ~~ Pod::Heading
         || ($part.?name !=:= Nil && $part.name eq 'para')
         ||  $part.?WHEREFORE !=:= Nil
     }).eager;

     $pod[0..*] = |$named-pod, |@code-sections;
}

DOC INIT {
    move-declarations-to-end($=pod);
}

