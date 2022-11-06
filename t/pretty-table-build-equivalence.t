use lib 'lib';
use Test;
use Prettier::Table;

plan 2;

# Row by row...
my $table-by-row = Prettier::Table.new;
$table-by-row.field-names(["City name", "Area", "Population", "Annual Rainfall"]);
$table-by-row.add-row(["Adelaide", 1295, 1158259, 600.5]);
$table-by-row.add-row(["Brisbane", 5905, 1857594, 1146.4]);
$table-by-row.add-row(["Darwin", 112, 120900, 1714.7]);
$table-by-row.add-row(["Hobart", 1357, 205556, 619.5]);
$table-by-row.add-row(["Sydney", 2058, 4336374, 1214.8]);
$table-by-row.add-row(["Melbourne", 1566, 3806092, 646.9]);
$table-by-row.add-row(["Perth", 5386, 1554769, 869.4]);

# Column by column...
my $table-by-column = Prettier::Table.new;
$table-by-column.add-column("City name", ["Adelaide", "Brisbane", "Darwin", "Hobart", "Sydney", "Melbourne", "Perth"]);
$table-by-column.add-column("Area", [1295, 5905, 112, 1357, 2058, 1566, 5386]);
$table-by-column.add-column("Population", [1158259, 1857594, 120900, 205556, 4336374, 3806092, 1554769]);
$table-by-column.add-column("Annual Rainfall", [600.5, 1146.4, 1714.7, 619.5, 1214.8, 646.9, 869.4]);

# Both rows and columns...
my $mixed-table = Prettier::Table.new;
$mixed-table.field-names(["City name", "Area"]);
$mixed-table.add-row(["Adelaide", 1295]);
$mixed-table.add-row(["Brisbane", 5905]);
$mixed-table.add-row(["Darwin", 112]);
$mixed-table.add-row(["Hobart", 1357]);
$mixed-table.add-row(["Sydney", 2058]);
$mixed-table.add-row(["Melbourne", 1566]);
$mixed-table.add-row(["Perth", 5386]);
$mixed-table.add-column("Population", [1158259, 1857594, 120900, 205556, 4336374, 3806092, 1554769]);
$mixed-table.add-column("Annual Rainfall", [600.5, 1146.4, 1714.7, 619.5, 1214.8, 646.9, 869.4]);

is $table-by-row.get-string,      $table-by-column.get-string,      'ASCII: Comparing table by row and table by column';
is $table-by-row.get-string,      $mixed-table.get-string,          'ASCII: Comparing table by row and mixed table';
