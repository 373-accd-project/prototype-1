import csv
import re

with open('area_codes.csv') as file, open('new_area_codes.csv', 'w') as o:
    reader = csv.reader(file)
    writer = csv.writer(o)
    reader.next()

    pattern = re.compile(", [A-Z][A-Z]$")
    states = dict()
    others = []

    for line in reader:
        if pattern.search(line[1]) != None:
            state = pattern.search(line[1]).group()
            state = state[-2:]
            if state in states:
                states[state] += [line]
            else:
                states[state] = [line]
        else:
            others += [line]

    for k, state in sorted(states.iteritems()):
        for s in state:
            writer.writerow(s)
        writer.writerow([-1,"NA"])

    for other in sorted(others):
        writer.writerow(other)
