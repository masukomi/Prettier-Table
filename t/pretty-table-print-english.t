use lib 'lib';
use Test;
use Prettier::Table;
use Prettier::Table::Constrains;

plan 2;

my $expected = q:to/END/;
┌─────────────────────────────────────────────────┐
│            Australian capital cities            │
├───────────┬──────┬────────────┬─────────────────┤
│ City name │ Area │ Population │ Annual Rainfall │
├───────────┼──────┼────────────┼─────────────────┤
│   Sydney  │ 2058 │  4336374   │      1214.8     │
│ Melbourne │ 1566 │  3806092   │      646.9      │
│  Brisbane │ 5905 │  1857594   │      1146.4     │
│   Perth   │ 5386 │  1554769   │      869.4      │
│  Adelaide │ 1295 │  1158259   │      600.5      │
│   Hobart  │ 1357 │   205556   │      619.5      │
│   Darwin  │ 112  │   120900   │      1714.7     │
└───────────┴──────┴────────────┴─────────────────┘
END

subtest 'table generated using setters', {
    my $x = Prettier::Table.new(
        field-names => ["City name", "Area", "Population", "Annual Rainfall"]
    );

    given $x {
        .title("Australian capital cities");
        .sort-by("Population");
        .reverse-sort(True);
        .add-row(("Adelaide", 1295, 1158259, 600.5));
        .add-row(("Brisbane", 5905, 1857594, 1146.4));
        .add-row(("Darwin", 112, 120900, 1714.7));
        .add-row(("Hobart", 1357, 205556, 619.5));
        .add-row(("Sydney", 2058, 4336374, 1214.8));
        .add-row(("Melbourne", 1566, 3806092, 646.9));
        .add-row(("Perth", 5386, 1554769, 869.4));
    }

    my $result = $x.get-string;
    ok $result.trim eq $expected.trim, "Resulting table equals to expected table";
}

subtest 'table generated using constructor arguments', {
    my $x = Prettier::Table.new(
        field-names => ["City name", "Area", "Population", "Annual Rainfall"],
        title => "Australian capital cities",
        sort-by => "Population",
        reverse-sort => True,
        #int-format => "04",
        #float-format => "6.1",
        #max-width => 12,
        #min-width => 4,
        #align => 'c',
        #valign => 't',
    );

    given $x {
        .add-row(("Adelaide", 1295, 1158259, 600.5));
        .add-row(("Brisbane", 5905, 1857594, 1146.4));
        .add-row(("Darwin", 112, 120900, 1714.7));
        .add-row(("Hobart", 1357, 205556, 619.5));
        .add-row(("Sydney", 2058, 4336374, 1214.8));
        .add-row(("Melbourne", 1566, 3806092, 646.9));
        .add-row(("Perth", 5386, 1554769, 869.4));
    }

    my $result = $x.get-string;
    ok $result.trim eq $expected.trim, "Resulting table equals to expected table";
}
