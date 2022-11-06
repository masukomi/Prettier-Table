use lib 'lib';
use Test;
use Prettier::Table;
use Prettier::Table::Constrains;

plan 2;

sub basic-setup( $table ) {
    my ($string, @lines, @lengths);
    $string = $table.get-string;
    @lines = $string.split("\n", :skip-empty);
    ok "" ∉ @lines, 'No table should ever have blank lines in it.';

    $string = $table.get-string;
    @lines = $string.split("\n", :skip-empty);
    @lengths = @lines.map(*.chars);
    ok @lengths.Set.elems == 1, 'All lines in a table should be of the same length.';
}

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

subtest 'run basic settings after setting an integer format string', {
    my $int = $table.clone;
    $int.int-format("04");
    basic-setup $int;
}

subtest 'run basic settings after setting a float format string', {
    my $float = $table.clone;
    $float.float-format("6.0f");
    basic-setup $float;
}
