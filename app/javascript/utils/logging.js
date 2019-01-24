const logStateAndProps = (type, name, thing) => {
    console.log(`\n~~~~~ ${type}: ${name}`);
    console.log("STATE");
    console.log(thing.state);
    console.log("PROPS");
    console.log(thing.props);
    console.log(`~~~~~ end ${type}: ${name}`);
}

export { logStateAndProps };