const Root: React.FC<{ name: string }> = ({ name }) => {
  return (
    <section>
      <div className="jumbotron">
        <h1 className="display-4">{name} is mounted!</h1>
        <p className="lead">
          This is a simple hero unit, a simple jumbotron-style component for calling extra attention
          to featured content or information.
        </p>
        <hr className="my-4" />
        <p>
          It uses utility classNames for typography and spacing to space content out within the
          larger container.
        </p>
        <p className="lead">
          {/* eslint-disable-next-line jsx-a11y/anchor-is-valid */}
          <a className="btn btn-primary btn-lg" href="#" role="button">
            Learn more
          </a>
        </p>
      </div>
    </section>
  );
};

export default Root;
