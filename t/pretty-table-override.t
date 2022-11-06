use lib 'lib';
use Test;
use Prettier::Table;
use Prettier::Table::Constrains;

plan 4;

my $table = Prettier::Table.new:
    field-names => ["city name", "area", "population", "annual rainfall"],
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

my ($default, $override);

$default = $table.get-string;
$override = $table.get-string(:!border);
isnt $default, $override, 'Disabling border makes tables not the same';

$default = $table.get-string;
$override = $table.get-string(:!header);
isnt $default, $override, 'Disabling header makes tables not the same';

$default = $table.get-string;
$override = $table.get-string(:hrules(ALL));
isnt $default, $override, 'Using different hrules makes tables not the same';

$default = $table.get-string;
$override = $table.get-string(:hrules(NONE));
isnt $default, $override, 'Using different hrules makes tables not the same';
