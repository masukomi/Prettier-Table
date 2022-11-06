use lib 'lib';
use Test;
use Prettier::Table;
use Prettier::Table::Constrains;

plan 5;

my Prettier::Table $x .= new:
    field-names => ["City name", "Area", "Population", "Annual Rainfall"],
;

given $x {
    .add-row(["Adelaide", 1295, 1158259, 600.5]);
    .add-row(["Brisbane", 5905, 1857594, 1146.4]);
    .add-row(["Darwin", 112, 120900, 1714.7]);
    .add-row(["Hobart", 1357, 205556, 619.5]);
    .add-row(["Sydney", 2058, 4336374, 1214.8]);
    .add-row(["Melbourne", 1566, 3806092, 646.9]);
    .add-row(["Perth", 5386, 1554769, 869.4]);
}

my Prettier::Table $y .= new:
    field-names => ["City name", "Area", "Population", "Annual Rainfall"],
;

# print-empty => True
isnt $y.get-string(:print-empty), "", 'Setting print-empty to True produces an empty table';
isnt $y.get-string(:print-empty), $x.get-string(:print-empty), 'An empty table isn\'t equal to populated table';

# print-empty => False
is $y.get-string(:!print-empty), "", 'Setting print-empty to False produces an empty string';
isnt $y.get-string(:!print-empty), $x.get-string(:!print-empty), 'An empty table isn\'t equal to populated table';

# interaction with border
is $y.get-string(:!border, :print-empty), '', 'Disabling borders from an empty table produces the empty string';
