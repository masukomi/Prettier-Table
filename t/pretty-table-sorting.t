use lib 'lib';
use Test;
use Prettier::Table;
use Prettier::Table::Constrains;

plan 4;

subtest 'sort-by', {
    my Prettier::Table $table .= new:
        field-names => ["City name", "Area", "Population", "Annual Rainfall"],
    ;

    given $table {
        .add-row(["Adelaide", 1295, 1158259, 600.5]);
        .add-row(["Brisbane", 5905, 1857594, 1146.4]);
        .add-row(["Darwin", 112, 120900, 1714.7]);
        .add-row(["Hobart", 1357, 205556, 619.5]);
        .add-row(["Sydney", 2058, 4336374, 1214.8]);
        .add-row(["Melbourne", 1566, 3806092, 646.9]);
        .add-row(["Perth", 5386, 1554769, 869.4]);
    }

    $table.sort-by($table.field-names[0]);
    my $old = $table.get-string;
    for $table.field-names[1..*] -> $field {
        $table.sort-by($field);
        my $new = $table.get-string;
        isnt $new, $old, 'New sorted table isn\'t equal to old table';
    }
}

subtest 'reverse-sort', {
    my Prettier::Table $table .= new:
        field-names => ["City name", "Area", "Population", "Annual Rainfall"],
    ;

    given $table {
        .add-row(["Adelaide", 1295, 1158259, 600.5]);
        .add-row(["Brisbane", 5905, 1857594, 1146.4]);
        .add-row(["Darwin", 112, 120900, 1714.7]);
        .add-row(["Hobart", 1357, 205556, 619.5]);
        .add-row(["Sydney", 2058, 4336374, 1214.8]);
        .add-row(["Melbourne", 1566, 3806092, 646.9]);
        .add-row(["Perth", 5386, 1554769, 869.4]);
    }

    for $table.field-names -> $field {
        $table.sort-by($field);

        $table.reverse-sort(False);
        my $forward = $table.get-string;

        $table.reverse-sort(True);
        my $backward = $table.get-string;

        # the grep is because bottom and top borders will be different and not interchangable
        # this test is about the content not the dividers
        my @forward-lines = $forward.split("\n")[2..*].grep({ $_.starts-with("│") });
        my @backward-lines = $backward.split("\n")[2..*].grep({ $_.starts-with("│") });
        @backward-lines .= reverse;

        ok @forward-lines eqv @backward-lines, 'Table and the reverse of its reverse equals table';
    }

}

subtest 'sort-key', {
    my Prettier::Table $table .= new:
        field-names => ["City name", "Area", "Population", "Annual Rainfall"],
    ;

    given $table {
        .add-row(["Adelaide", 1295, 1158259, 600.5]);
        .add-row(["Brisbane", 5905, 1857594, 1146.4]);
        .add-row(["Darwin", 112, 120900, 1714.7]);
        .add-row(["Hobart", 1357, 205556, 619.5]);
        .add-row(["Sydney", 2058, 4336374, 1214.8]);
        .add-row(["Melbourne", 1566, 3806092, 646.9]);
        .add-row(["Perth", 5386, 1554769, 869.4]);
    }

    sub sort-by-length { $^key.chars }

    $table.sort-by('City name');
    $table.sort-key(&sort-by-length);
    my $result = $table.get-string;
    my $expected = q:to/END/;
    ┌───────────┬──────┬────────────┬─────────────────┐
    │ City name │ Area │ Population │ Annual Rainfall │
    ├───────────┼──────┼────────────┼─────────────────┤
    │   Perth   │ 5386 │  1554769   │      869.4      │
    │   Darwin  │ 112  │   120900   │      1714.7     │
    │   Hobart  │ 1357 │   205556   │      619.5      │
    │   Sydney  │ 2058 │  4336374   │      1214.8     │
    │  Adelaide │ 1295 │  1158259   │      600.5      │
    │  Brisbane │ 5905 │  1857594   │      1146.4     │
    │ Melbourne │ 1566 │  3806092   │      646.9      │
    └───────────┴──────┴────────────┴─────────────────┘
    END

    is $result.trim, $expected.trim, 'Sorted table equals to expected table';
}

subtest 'old-sort-slice', {
    my Prettier::Table $table .= new:
        field-names => ["Foo"],
    ;

    for 20 ... 1 -> $i {
        $table.add-row([$i]);
    }

    my $new-style = $table.get-string(:sort-by<Foo>, :end(10));
    ok $new-style.contains('10'), 'When False, new table contains row 10';
    nok $new-style.contains('20'), 'When False, new table doesn\'t contain row 20';

    my $old-style = $table.get-string(:sort-by<Foo>, :end(10), :old-sort-slice);
    nok $old-style.contains('10'), 'When True, new table doesn\'t contain row 10';
    ok $old-style.contains('20'), 'When True, new table contains row 20';
}
