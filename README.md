Name
====

`Pretty::Table`, a simple Raku module to make it quick and easy to represent tabular data in visually appealing ASCII tables.

`Pretty::Table` is a port of the Python library [PTable](https://github.com/kxxoling/PTable).

**Disclaimer:** This module is still a work in progress. Although some basic features are implemented, they still require further testing.

Synopsis
========

**Example 1**:

    use Pretty::Table;

    my $table = Pretty::Table.new:
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

Output:
```
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
```
**Example 2**:

    use Pretty::Table;

    my $table = Pretty::Table.new;

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
    $table.junction-char('*');

    put $table;

Output:
```
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
```

Installation
============

Using zef:

    zef install Pretty::Table

From source:

    $ git clone 
    $ cd raku-pretty-table
    $ zef install .

Quickstart
==========

`Pretty::Table` supports two kinds of usage:

As a module
-----------

    use Pretty::Table;
    my $x = Pretty::Table.new;

Read the section **Getter and Setter Methods** to find about the public attributes and their respective methods. For the [tutorial](https://gitlab.com/uzluisf/raku-pretty-table/tree/master/doc/Pretty/Table/Tutorial.rakumod), run `p6doc Pretty::Table::Tutorial`.

As a command-line tool
----------------------

    pt --csv somefile.csv

Run `pt` to get the full usage message.

Methods
=======

Getter and Setter Methods
-------------------------

**NOTE**: These methods's names are the same as their respective attributes. To set a specific attribute during the instantiation of a `Pretty::Table` object, use its method's name. For instance, to set `title`, `Pretty::Table.new(title => "Table's title")`. Thus, all methods listed here have an associated attribute that can be set during object construction.

### multi method field-names

```perl6
multi method field-names() returns Array
```

Return a list of field names.

### multi method field-names

```perl6
multi method field-names(
    @values
) returns Nil
```

Set a list of field names.

### multi method align

```perl6
multi method align() returns Hash
```

Return how the alignment of fields is controlled.

### multi method align

```perl6
multi method align(
    $val
) returns Nil
```

Set how the alignment of fields is controlled. Either an alignment string (l, c, or r) or a hash of field-to-alignment pairs.

### multi method valign

```perl6
multi method valign() returns Hash
```

Return how the vertical alignment of fields is controlled.

### multi method valign

```perl6
multi method valign(
    $val
) returns Nil
```

Set how the vertical alignment of fields is controlled. Either an alignment string (t, m, or b) or a hash of field-to-alignment pairs.

### multi method max-width

```perl6
multi method max-width() returns Pretty::Table::Constrains::NonNeg
```

Return the maximum width of fields.

### multi method max-width

```perl6
multi method max-width(
    $val where { ... }
) returns Nil
```

Set the maximum width of fields.

### multi method min-width

```perl6
multi method min-width() returns Hash
```

Return the minimum width of fields.

### multi method min-width

```perl6
multi method min-width(
    $val where { ... }
) returns Nil
```

Set the minimum width of fields.

### multi method min-table-width

```perl6
multi method min-table-width() returns Pretty::Table::Constrains::NonNeg
```

Return the minimum desired table width, in characters.

### multi method min-table-width

```perl6
multi method min-table-width(
    $val where { ... }
) returns Mu
```

Set the minimum desired table width, in characters.

### multi method max-table-width

```perl6
multi method max-table-width() returns Mu
```

Return the maximum desired table width, in characters.

### multi method max-table-width

```perl6
multi method max-table-width(
    $val where { ... }
) returns Mu
```

Set the minimum desired table width, in characters.

### multi method fields

```perl6
multi method fields() returns Array
```

Return the list of field names to include in displays.

### multi method fields

```perl6
multi method fields(
    @values
) returns Mu
```

Return the list of field names to include in displays.

### multi method title

```perl6
multi method title() returns Str
```

Return the table title (if existent).

### multi method title

```perl6
multi method title(
    Str $val
) returns Mu
```

Set the table title.

### multi method start

```perl6
multi method start() returns Pretty::Table::Constrains::NonNeg
```

Return the start index of the range of rows to print.

### multi method start

```perl6
multi method start(
    $val where { ... }
) returns Mu
```

Set the start index of the range of rows to print.

### multi method end

```perl6
multi method end() returns Mu
```

Return the end index of the range of rows to print.

### multi method end

```perl6
multi method end(
    $val
) returns Mu
```

Set the end index of the range of rows to print.

### multi method sort-by

```perl6
multi method sort-by() returns Mu
```

Return the name of field by which to sort rows.

### multi method sort-by

```perl6
multi method sort-by(
    Str $val where { ... }
) returns Mu
```

Set the name of field by which to sort rows.

### multi method reverse-sort

```perl6
multi method reverse-sort() returns Bool
```

Return the direction of sorting, ascending (False) vs descending (True).

### multi method reverse-sort

```perl6
multi method reverse-sort(
    Bool $val
) returns Nil
```

Set the direction of sorting (ascending (False) vs descending (True).

### multi method sort-key

```perl6
multi method sort-key() returns Callable
```

Return the sorting key function, applied to data points before sorting.

### multi method sort-key

```perl6
multi method sort-key(
    &val
) returns Nil
```

Set the sorting key function, applied to data points before sorting.

### multi method header

```perl6
multi method header() returns Bool
```

Return whether the table has a heading showing the field names.

### multi method header

```perl6
multi method header(
    Bool $val
) returns Nil
```

Set whether the table has a heading showing the field names.

### multi method header-style

```perl6
multi method header-style() returns Pretty::Table::Constrains::HeaderStyle
```

Return style to apply to field names in header ("cap", "title", "upper", or "lower").

### multi method header-style

```perl6
multi method header-style(
    $val where { ... }
) returns Mu
```

Set style to apply to field names in header ("cap", "title", "upper", or "lower").

### multi method border

```perl6
multi method border() returns Bool
```

Return whether a border is printed around table.

### multi method border

```perl6
multi method border(
    Bool $val
) returns Mu
```

Set whether a border is printed around table.

### multi method hrules

```perl6
multi method hrules() returns Pretty::Table::Constrains::HorizontalRule
```

Return how horizontal rules are printed after rows.

### multi method hrules

```perl6
multi method hrules(
    $val where { ... }
) returns Mu
```

Set how horizontal rules are printed after rows. Allowed values: FRAME, ALL, HEADER, NONE

### multi method vrules

```perl6
multi method vrules() returns Pretty::Table::Constrains::VerticalRule
```

Return how vertical rules are printed between columns.

### multi method vrules

```perl6
multi method vrules(
    $val where { ... }
) returns Mu
```

Set how vertical rules are printed between columns. Allowed values: FRAME, ALL, NONE

### multi method int-format

```perl6
multi method int-format() returns Mu
```

Return how the integer data is formatted.

### multi method int-format

```perl6
multi method int-format(
    $val
) returns Nil
```

Set how the integer data is formatted. The value can either be a string or a hash of field-to-format pairs.

### multi method float-format

```perl6
multi method float-format() returns Mu
```

Return how the integer data is formatted.

### multi method float-format

```perl6
multi method float-format(
    $val
) returns Nil
```

Set how the integer data is formatted. The value can either be a string or a hash of field-to-format pairs.

### multi method padding-width

```perl6
multi method padding-width() returns Pretty::Table::Constrains::NonNeg
```

Return the number of empty spaces between a column's edge and its content.

### multi method padding-width

```perl6
multi method padding-width(
    $val where { ... }
) returns Nil
```

Set the number of empty spaces between a column's edge and its content.

### multi method left-padding-width

```perl6
multi method left-padding-width() returns Pretty::Table::Constrains::NonNeg
```

Return the number of empty spaces between a column's left edge and its content.

### multi method left-padding-width

```perl6
multi method left-padding-width(
    $val where { ... }
) returns Nil
```

Set the number of empty spaces between a column's left edge and its content.

### multi method right-padding-width

```perl6
multi method right-padding-width() returns Pretty::Table::Constrains::NonNeg
```

Return the number of empty spaces between a column's right edge and its content.

### multi method right-padding-width

```perl6
multi method right-padding-width(
    $val where { ... }
) returns Nil
```

Set the number of empty spaces between a column's right edge and its content.

### multi method vertical-char

```perl6
multi method vertical-char() returns Pretty::Table::Constrains::Char
```

Return character used when printing table borders to draw vertical lines.

### multi method vertical-char

```perl6
multi method vertical-char(
    $val where { ... }
) returns Nil
```

Return character used when printing table borders to draw vertical lines.

### multi method horizontal-char

```perl6
multi method horizontal-char() returns Pretty::Table::Constrains::Char
```

Return character used when printing table borders to draw horizontal lines.

### multi method horizontal-char

```perl6
multi method horizontal-char(
    $val where { ... }
) returns Nil
```

Return character used when printing table borders to draw horizontal lines.

### multi method junction-char

```perl6
multi method junction-char() returns Pretty::Table::Constrains::Char
```

Return character used when printing table borders to draw line junctions.

### multi method junction-char

```perl6
multi method junction-char(
    $val where { ... }
) returns Nil
```

Return character used when printing table borders to draw line junctions.

### multi method format

```perl6
multi method format() returns Bool
```

Return whether or not HTML tables are formatted to match styling options.

### multi method format

```perl6
multi method format(
    Bool $val
) returns Nil
```

Set whether or not HTML tables are formatted to match styling options.

### multi method print-empty

```perl6
multi method print-empty() returns Bool
```

Return whether or not empty tables produce a header and frame or just an empty string.

### multi method print-empty

```perl6
multi method print-empty(
    Bool $val
) returns Nil
```

Set whether or not empty tables produce a header and frame or just an empty string.

### multi method old-sort-slice

```perl6
multi method old-sort-slice() returns Bool
```

Return whether to slice rows before sorting in the "old style".

### multi method old-sort-slice

```perl6
multi method old-sort-slice(
    Bool $val
) returns Nil
```

Return whether to slice rows before sorting in the "old style".

Style of Table
--------------

### method set-style

```perl6
method set-style(
    TableStyle $style
) returns Nil
```

Set the style to be used for the table. Allowed values: DEFAULT: Show header and border, hrules and vrules are FRAME and ALL respectively, paddings are 1, vert. char is |, hor. char is -, and junction char is +. MSWORD-FRIENDLY: Show header and border, hrules is NONE, paddings are 1, and vert. char is | PLAIN-COLUMNS: Show header and hide border, hrules is NONE, padding is 1, left padding is 0, and right padding is 8 RANDOM: random style

Data Input Methods
------------------

### method add-row

```perl6
method add-row(
    @row
) returns Nil
```

Add a row to the table.

class Mu $
----------

Row of data, should be a list with as many elements as the table has fields.

### method del-row

```perl6
method del-row(
    Int $row-index
) returns Nil
```

Delete a row from the table.

class Mu $
----------

Index of the row to delete (0-based index).

### method add-column

```perl6
method add-column(
    Str $fieldname,
    @column,
    $align where { ... } = "c",
    $valign where { ... } = "m"
) returns Nil
```

Add a column to the table.

class Mu $
----------

Name of the field to contain the new column of data.

class Mu $
----------

Column of data, should be a list with as many elements as the table has rows.

class Mu $
----------

Desired alignment for this column - "l" (left), "c" (center), and "r" (right).

class Mu $
----------

Desired vertical alignment for new columns - "t" (top), "m" (middle), and "b" (bottom).

### method clear-rows

```perl6
method clear-rows() returns Nil
```

Delete all rows from the table but keep the current field names.

### method clear

```perl6
method clear() returns Nil
```

Delete all rows and field names from the table, maintaining nothing but styling options.

Plain Text String methods
-------------------------

### method get-string

```perl6
method get-string(
    Str :$title = Str,
    :$start where { ... } = Pretty::Table::Constrains::NonNeg,
    :$end where { ... } = Pretty::Table::Constrains::NonNeg,
    :@fields,
    Bool :$header = Bool,
    Bool :$border = Bool,
    :$hrules where { ... } = Pretty::Table::Constrains::HorizontalRule,
    :$vrules where { ... } = Pretty::Table::Constrains::VerticalRule,
    Str :$int-format = Str,
    Str :$float-format = Str,
    :$padding-width where { ... } = Pretty::Table::Constrains::NonNeg,
    :$left-padding-width where { ... } = Pretty::Table::Constrains::NonNeg,
    :$right-padding-width where { ... } = Pretty::Table::Constrains::NonNeg,
    :$vertical-char where { ... } = Pretty::Table::Constrains::Char,
    :$horizontal-char where { ... } = Pretty::Table::Constrains::Char,
    :$junction-char where { ... } = Pretty::Table::Constrains::Char,
    Str :$sort-by = Str,
    :&sort-key,
    Bool :$reverse-sort = Bool,
    Bool :$old-sort-slice = Bool,
    Bool :$print-empty = Bool
) returns Str
```

Return string representation of table in current state.

class Mu $
----------

See method title

class Mu $
----------

See method start

class Mu $
----------

See method end

class Mu $
----------

See method fields

class Mu $
----------

See method header

class Mu $
----------

See method border

class Mu $
----------

See method hrules

class Mu $
----------

See method vrules

class Mu $
----------

See method int-format

class Mu $
----------

See method float-format

class Mu $
----------

See method padding-width

class Mu $
----------

See method left-padding-width

class Mu $
----------

See method right-padding-width

class Mu $
----------

See method vertical-char

class Mu $
----------

See method horizontal-char

class Mu $
----------

See method junction-char

class Mu $
----------

See method sort-by

class Mu $
----------

See method sort-key

class Mu $
----------

See method reverse-sort

class Mu $
----------

see method old-sort-slice

class Mu $
----------

See method print-empty

Miscellaneous Methods
---------------------

### method row-count

```perl6
method row-count() returns Int
```

Return the number of rows.

### method col-count

```perl6
method col-count() returns Int
```

Return the number of columns.

