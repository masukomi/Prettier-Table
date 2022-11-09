Name
====

`Prettier::Table`, a simple Raku module to make it quick and easy to represent tabular data in visually appealing ASCII tables.

By default it will generate tables using ASCII Box Drawing characters as show in the examples below. But you can also generate [GFM Markdown tables](https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/organizing-information-with-tables), and MS Word Friendly tables by calling `$my_table.set-style('MARKDOWN')` or `$my_table.set-style('MSWORD-FRIENDLY')` Check out `demo.raku` to see this in action.

This is a fork of [Luis F Uceta's Prettier::Table](https://gitlab.com/uzluisf/raku-pretty-table) which is itself a port of the [Kane Blueriver's PTable library for Python](https://github.com/kxxoling/PTable).

Synopsis
========

**Example 1**:

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

Output:

<img alt="actual rendering" src="https://github.com/masukomi/Prettier-Table/blob/images/images/australian_cities.png?raw=true" />

(GitHub displays the raw text incorrectly)

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

**Example 2**:

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

Output:

<img alt="actual rendering" src="https://github.com/masukomi/Prettier-Table/blob/images/images/planets_of_the_solar_system.png?raw=true" />

(GitHub displays the raw text incorrectly)

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

Installation
============

Using zef:

    zef install Prettier::Table

From source:

    $ git clone
    $ cd raku-pretty-table
    $ zef install .

Quickstart
==========

`Prettier::Table` supports two kinds of usage:

As a module
-----------

    use Prettier::Table;
    my $x = Prettier::Table.new;

Check out the attributes in `Prettier::Table` to see the full list of things that can be set / configured. Most notably the `*-char` attributes, used to control the look of the border. Additionally, the named parameters in the `get-string` method.

AUTHORS
-------

  * [Luis F Uceta's Prettier::Table](https://gitlab.com/uzluisf/raku-pretty-table)

  * [masukomi](https://masukomi.org)

LICENSE
-------

MIT. See LICENSE file.

Methods
=======

Getter and Setter Methods
-------------------------

**NOTE**: These methods's names are the same as their respective attributes. To set a specific attribute during the instantiation of a `Prettier::Table` object, use its method's name. For instance, to set `title`, `Prettier::Table.new(title => "Table's title")`. Thus, all methods listed here have an associated attribute that can be set during object construction.

### multi method field-names

```raku
multi method field-names() returns Array
```

Return a list of field names.

### multi method field-names

```raku
multi method field-names(
    @values
) returns Nil
```

Set a list of field names.

### multi method align

```raku
multi method align() returns Hash
```

Return how the alignment of fields is controlled.

### multi method align

```raku
multi method align(
    $val
) returns Nil
```

Set how the alignment of fields is controlled. Either an alignment string (l, c, or r) or a hash of field-to-alignment pairs.

### multi method valign

```raku
multi method valign() returns Hash
```

Return how the vertical alignment of fields is controlled.

### multi method valign

```raku
multi method valign(
    $val
) returns Nil
```

Set how the vertical alignment of fields is controlled. Either an alignment string (t, m, or b) or a hash of field-to-alignment pairs.

### multi method max-width

```raku
multi method max-width() returns Prettier::Table::Constrains::NonNeg
```

Return the maximum width of fields.

### multi method max-width

```raku
multi method max-width(
    $val where { ... }
) returns Nil
```

Set the maximum width of fields.

### multi method min-width

```raku
multi method min-width() returns Hash
```

Return the minimum width of fields.

### multi method min-width

```raku
multi method min-width(
    $val
) returns Nil
```

Set the minimum width of fields.

### multi method min-table-width

```raku
multi method min-table-width() returns Prettier::Table::Constrains::NonNeg
```

Return the minimum desired table width, in characters.

### multi method min-table-width

```raku
multi method min-table-width(
    $val where { ... }
) returns Mu
```

Set the minimum desired table width, in characters.

### multi method max-table-width

```raku
multi method max-table-width() returns Mu
```

Return the maximum desired table width, in characters.

### multi method max-table-width

```raku
multi method max-table-width(
    $val where { ... }
) returns Mu
```

Set the minimum desired table width, in characters.

### multi method fields

```raku
multi method fields() returns Array
```

Return the list of field names to include in displays.

### multi method fields

```raku
multi method fields(
    @values
) returns Mu
```

Return the list of field names to include in displays.

### multi method title

```raku
multi method title() returns Str
```

Return the table title (if existent).

### multi method title

```raku
multi method title(
    Str $val
) returns Mu
```

Set the table title.

### multi method start

```raku
multi method start() returns Prettier::Table::Constrains::NonNeg
```

Return the start index of the range of rows to print.

### multi method start

```raku
multi method start(
    $val where { ... }
) returns Mu
```

Set the start index of the range of rows to print.

### multi method end

```raku
multi method end() returns Mu
```

Return the end index of the range of rows to print.

### multi method end

```raku
multi method end(
    $val
) returns Mu
```

Set the end index of the range of rows to print.

### multi method sort-by

```raku
multi method sort-by() returns Mu
```

Return the name of field by which to sort rows.

### multi method sort-by

```raku
multi method sort-by(
    Str $val where { ... }
) returns Mu
```

Set the name of field by which to sort rows.

### multi method reverse-sort

```raku
multi method reverse-sort() returns Bool
```

Return the direction of sorting, ascending (False) vs descending (True).

### multi method reverse-sort

```raku
multi method reverse-sort(
    Bool $val
) returns Nil
```

Set the direction of sorting (ascending (False) vs descending (True).

### multi method sort-key

```raku
multi method sort-key() returns Callable
```

Return the sorting key function, applied to data points before sorting.

### multi method sort-key

```raku
multi method sort-key(
    &val
) returns Nil
```

Set the sorting key function, applied to data points before sorting.

### multi method header

```raku
multi method header() returns Bool
```

Return whether the table has a heading showing the field names.

### multi method header

```raku
multi method header(
    Bool $val
) returns Nil
```

Set whether the table has a heading showing the field names.

### multi method header-style

```raku
multi method header-style() returns Prettier::Table::Constrains::HeaderStyle
```

Return style to apply to field names in header ("cap", "title", "upper", or "lower").

### multi method header-style

```raku
multi method header-style(
    $val where { ... }
) returns Mu
```

Set style to apply to field names in header ("cap", "title", "upper", or "lower").

### multi method border

```raku
multi method border() returns Bool
```

Return whether a border is printed around table.

### multi method border

```raku
multi method border(
    Bool $val
) returns Mu
```

Set whether a border is printed around table.

### multi method hrules

```raku
multi method hrules() returns Prettier::Table::Constrains::HorizontalRule
```

Return how horizontal rules are printed after rows.

### multi method hrules

```raku
multi method hrules(
    $val where { ... }
) returns Mu
```

Set how horizontal rules are printed after rows. Allowed values: FRAME, ALL, HEADER, NONE

### multi method vrules

```raku
multi method vrules() returns Prettier::Table::Constrains::VerticalRule
```

Return how vertical rules are printed between columns.

### multi method vrules

```raku
multi method vrules(
    $val where { ... }
) returns Mu
```

Set how vertical rules are printed between columns. Allowed values: FRAME, ALL, NONE

### multi method int-format

```raku
multi method int-format() returns Mu
```

Return how the integer data is formatted.

### multi method int-format

```raku
multi method int-format(
    $val
) returns Nil
```

Set how the integer data is formatted. The value can either be a string or a hash of field-to-format pairs.

### multi method float-format

```raku
multi method float-format() returns Mu
```

Return how the integer data is formatted.

### multi method float-format

```raku
multi method float-format(
    $val
) returns Nil
```

Set how the integer data is formatted. The value can either be a string or a hash of field-to-format pairs.

### multi method padding-width

```raku
multi method padding-width() returns Prettier::Table::Constrains::NonNeg
```

Return the number of empty spaces between a column's edge and its content.

### multi method padding-width

```raku
multi method padding-width(
    $val where { ... }
) returns Nil
```

Set the number of empty spaces between a column's edge and its content.

### multi method left-padding-width

```raku
multi method left-padding-width() returns Prettier::Table::Constrains::NonNeg
```

Return the number of empty spaces between a column's left edge and its content.

### multi method left-padding-width

```raku
multi method left-padding-width(
    $val where { ... }
) returns Nil
```

Set the number of empty spaces between a column's left edge and its content.

### multi method right-padding-width

```raku
multi method right-padding-width() returns Prettier::Table::Constrains::NonNeg
```

Return the number of empty spaces between a column's right edge and its content.

### multi method right-padding-width

```raku
multi method right-padding-width(
    $val where { ... }
) returns Nil
```

Set the number of empty spaces between a column's right edge and its content.

### multi method vertical-char

```raku
multi method vertical-char() returns Prettier::Table::Constrains::Char
```

Return character used when printing table borders to draw vertical lines.

### multi method vertical-char

```raku
multi method vertical-char(
    $val where { ... }
) returns Nil
```

Set character used when printing table borders to draw vertical lines.

### multi method horizontal-char

```raku
multi method horizontal-char() returns Prettier::Table::Constrains::Char
```

Return character used when printing table borders to draw horizontal lines.

### multi method horizontal-char

```raku
multi method horizontal-char(
    $val where { ... }
) returns Nil
```

Set character used when printing table borders to draw horizontal lines.

### multi method junction-char

```raku
multi method junction-char() returns Prettier::Table::Constrains::Char
```

Return character used when printing table borders to draw mid-line junctions.

### multi method junction-char

```raku
multi method junction-char(
    $val where { ... }
) returns Nil
```

Set character used when printing table borders to draw mid-line junctions.

### multi method left-junction-char

```raku
multi method left-junction-char() returns Prettier::Table::Constrains::Char
```

Return character used when printing table borders to draw left-edge line junctions.

### multi method left-junction-char

```raku
multi method left-junction-char(
    $val where { ... }
) returns Nil
```

Set character used when printing table borders to draw left-edge line junctions.

### multi method right-junction-char

```raku
multi method right-junction-char() returns Prettier::Table::Constrains::Char
```

Return character used when printing table borders to draw right-edge line junctions.

### multi method right-junction-char

```raku
multi method right-junction-char(
    $val where { ... }
) returns Nil
```

Set character used when printing table borders to draw right-edge line junctions.

### multi method top-junction-char

```raku
multi method top-junction-char() returns Prettier::Table::Constrains::Char
```

Return character used when printing table borders to draw top edge mid-line junctions.

### multi method top-junction-char

```raku
multi method top-junction-char(
    $val where { ... }
) returns Nil
```

Set character used when printing table borders to draw top edge mid-line junctions.

### multi method bottom-junction-char

```raku
multi method bottom-junction-char() returns Prettier::Table::Constrains::Char
```

Return character used when printing table borders to draw bottom edge mid-line junctions.

### multi method bottom-junction-char

```raku
multi method bottom-junction-char(
    $val where { ... }
) returns Nil
```

Set character used when printing table borders to draw bottom edge mid-line junctions.

### multi method bottom-left-corner-char

```raku
multi method bottom-left-corner-char() returns Prettier::Table::Constrains::Char
```

Return character used when printing table borders to draw bottem edge left corners.

### multi method bottom-left-corner-char

```raku
multi method bottom-left-corner-char(
    $val where { ... }
) returns Nil
```

Set character used when printing table borders to draw bottom edge left corners.

### multi method bottom-right-corner-char

```raku
multi method bottom-right-corner-char() returns Prettier::Table::Constrains::Char
```

Return character used when printing table borders to draw bottom right corners.

### multi method bottom-right-corner-char

```raku
multi method bottom-right-corner-char(
    $val where { ... }
) returns Nil
```

Set character used when printing table borders to draw bottom right corners.

### multi method top-left-corner-char

```raku
multi method top-left-corner-char() returns Prettier::Table::Constrains::Char
```

Return character used when printing table borders to draw top left corners.

### multi method top-left-corner-char

```raku
multi method top-left-corner-char(
    $val where { ... }
) returns Nil
```

Set character used when printing table borders to top left corners.

### multi method top-right-corner-char

```raku
multi method top-right-corner-char() returns Prettier::Table::Constrains::Char
```

Return character used when printing table borders to top right corners.

### multi method top-right-corner-char

```raku
multi method top-right-corner-char(
    $val where { ... }
) returns Nil
```

Set character used when printing table borders to draw top right corners.

### multi method format

```raku
multi method format() returns Bool
```

Return whether or not HTML tables are formatted to match styling options.

### multi method format

```raku
multi method format(
    Bool $val
) returns Nil
```

Set whether or not HTML tables are formatted to match styling options.

### multi method print-empty

```raku
multi method print-empty() returns Bool
```

Return whether or not empty tables produce a header and frame or just an empty string.

### multi method print-empty

```raku
multi method print-empty(
    Bool $val
) returns Nil
```

Set whether or not empty tables produce a header and frame or just an empty string.

### multi method old-sort-slice

```raku
multi method old-sort-slice() returns Bool
```

Return whether to slice rows before sorting in the "old style".

### multi method old-sort-slice

```raku
multi method old-sort-slice(
    Bool $val
) returns Nil
```

Return whether to slice rows before sorting in the "old style".

Style of Table
--------------

### multi method set-style

```raku
multi method set-style(
    TableStyle $style
) returns Nil
```

Set the style to be used for the table. Allowed values: DEFAULT: Show header and border, hrules and vrules are FRAME and ALL respectively, paddings are 1, ASCII Box Drawing characters used for borders. MSWORD-FRIENDLY: Show header and border, hrules is NONE, paddings are 1, and vert. char is | MARKDOWN: GitHub Flavored Markdown table. - Removes title, only hrule below column headers, paddings are 1, and vert. char is | PLAIN-COLUMNS: Show header and hide border, hrules is NONE, padding is 1, left padding is 0, and right padding is 8 RANDOM: random style

### method set-default-style

```raku
method set-default-style() returns Nil
```

Single character string used to draw vertical lines. Single character string used to draw horizontal lines. Single character string used to draw line junctions.

### method set-markdown-style

```raku
method set-markdown-style() returns Nil
```

modifies border characters to produce markdown output

Data Input Methods
------------------

### method add-row

```raku
method add-row(
    @row
) returns Nil
```

Add a row to the table.

class Mu $
----------

Row of data, should be a list with as many elements as the table has fields.

### method del-row

```raku
method del-row(
    Int $row-index
) returns Nil
```

Delete a row from the table.

class Mu $
----------

Index of the row to delete (0-based index).

### method add-column

```raku
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

```raku
method clear-rows() returns Nil
```

Delete all rows from the table but keep the current field names.

### method clear

```raku
method clear() returns Nil
```

Delete all rows and field names from the table, maintaining nothing but styling options.

Plain Text String methods
-------------------------

### method get-string

```raku
method get-string(
    Str :$title = Str,
    :$start where { ... } = Prettier::Table::Constrains::NonNeg,
    :$end where { ... } = Prettier::Table::Constrains::NonNeg,
    :@fields,
    Bool :$header = Bool,
    Bool :$border = Bool,
    :$hrules where { ... } = Prettier::Table::Constrains::HorizontalRule,
    :$vrules where { ... } = Prettier::Table::Constrains::VerticalRule,
    Str :$int-format = Str,
    Str :$float-format = Str,
    :$padding-width where { ... } = Prettier::Table::Constrains::NonNeg,
    :$left-padding-width where { ... } = Prettier::Table::Constrains::NonNeg,
    :$right-padding-width where { ... } = Prettier::Table::Constrains::NonNeg,
    :$vertical-char where { ... } = Prettier::Table::Constrains::Char,
    :$horizontal-char where { ... } = Prettier::Table::Constrains::Char,
    :$junction-char where { ... } = Prettier::Table::Constrains::Char,
    :$left-junction-char where { ... } = Prettier::Table::Constrains::Char,
    :$right-junction-char where { ... } = Prettier::Table::Constrains::Char,
    :$top-junction-char where { ... } = Prettier::Table::Constrains::Char,
    :$bottom-junction-char where { ... } = Prettier::Table::Constrains::Char,
    :$bottom-left-corner-char where { ... } = Prettier::Table::Constrains::Char,
    :$bottom-right-corner-char where { ... } = Prettier::Table::Constrains::Char,
    :$top-left-corner-char where { ... } = Prettier::Table::Constrains::Char,
    :$top-right-corner-char where { ... } = Prettier::Table::Constrains::Char,
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

See method junction-char

class Mu $
----------

See method right-junction-char

class Mu $
----------

See method top-junction-char

class Mu $
----------

See method bottom-junction-char

class Mu $
----------

See method bottom-left-corner-char

class Mu $
----------

See method bottom-right-corner-char

class Mu $
----------

See method top-left-corner-char

class Mu $
----------

See method top-right-corner-char

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

```raku
method row-count() returns Int
```

Return the number of rows.

### method col-count

```raku
method col-count() returns Int
```

Return the number of columns.

### method slice

```raku
method slice(
    *@indices
) returns Prettier::Table
```

Return a sliced-off new Prettier::Table. The indices must between 0 and the table's number of rows (exclusive). Alternatively, the postcircumfix operator [] can be used.

