unit module Prettier::Table::Constrains;

#
# Enumerations
#

# Horizontal rules between a table's rows:
#   FRAME, the table has rules (outerpart)
#   ALL, everything has rules
#   HEADER, only the header has rules
#   NONE, nothing has rules
enum hrules-enum is export <FRAME ALL NONE HEADER>;

enum TableStyle is export (:10DEFAULT, :11MSWORD-FRIENDLY, :12PLAIN-COLUMNS, :20RANDOM);

#
# Subsets
#

subset NonNeg is export
where ($_ ~~ Int || die "Value ({$_.raku}) must be an integer.")
   && ($_ ≥ 0    || die "Integer must not be negative.")
;

subset HeaderStyle is export
where ($_ ~~ Str || die "Header style must be a string.")
   && ($_ eq <cap title upper lower>.one || die "Invalid header style ($_). Use cap, title, upper, or lower.")
;

subset Align is export
where ($_ ~~ Str         || die "Alignment must be a string.")
   && ($_.chars == 1     || die "Value ($_) must be a single character.")
   && ($_ eq <l c r>.one || die "Alignment ($_) is invalid. Use l, c, or r.")
;

subset VAlign is export
where ($_ ~~ Str         || die "Alignment must be a string.")
   && ($_.chars == 1     || die "Value ($_) must be a single character.")
   && ($_ eq <t m b>.one || die "Alignment ($_) is invalid. Use t, m, or b.")
;

subset HorizontalRule is export
where ($_ ~~ hrules-enum || die "Invalid value ($_). Value must be ALL, FRAME, NONE, or HEADER.")
;

subset VerticalRule is export
where ($_ ~~ (ALL, FRAME, NONE).one || die "Invalid value ($_). Value must be ALL, FRAME, or NONE.")
;

subset Char is export
where ($_ ~~ Str     || die "Value must be a string.")
   && ($_.chars == 1 || die "Value ($_) must be a single character.")
;


sub validate-format( $val --> Bool ) {
    return True if $val ~~ Str | Hash;
    return False;
}
subset Format is export
where validate-format($_) || die 'Format must be a string or a hash of field-to-format pairs.';

sub validate-align( $val ) is export {
    die "Alignment must be a string." unless $val ~~ Str;
    die "Value ($_) must be a single character." unless $val.chars == 1;
    die "Alignment ($_) is invalid. Use l, c, or r." unless $val ~~ Align;
}

sub validate-valign( $val ) is export {
    die "Alignment must be a string." unless $val ~~ Str;
    die "Value ($_) must be a single character." unless $val.chars == 1;
    die "Alignment ($_) is invalid. Use t, m, or b." unless $val ~~ VAlign;
}



sub validate-field-names( :@values, :@field-names, :@rows ) is export {
    if @field-names {
        unless @values.elems == @field-names.elems {
            die "Field name list has incorrect number of values, (actual) {@values.elems} != {@field-names} (expected)"
        }
    }

    if @rows {
        unless @values.elems == @rows[0].elems {
            die "Field name list has incorrect number of values, (actual) {@values.elems} != {@field-names} (expected)"
        }

    }

    # check for uniqueness
    unless @values.elems == @values.Set.elems {
        die "Field names must be unique."
    }
}

sub validate-all-field-names( :@values, :@field-names ) is export {
    sub validate-field-name( :$value, :@field-names ) {
        unless $value ∈  @field-names or !$value.defined {
            die "Invalid field name"
        }
    }

    try {
        for @values -> $value {
            validate-field-name(:$value, :@field-names)
        }
    }

    if $! {
        die "Fields must be a sequence of field names"
    }
}