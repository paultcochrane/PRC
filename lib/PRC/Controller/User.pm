package PRC::Controller::User;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=encoding utf8

=head1 NAME

PRC::Controller::User - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 check_user_status

A private action that can make sure user
- is logged in
- has an active account (not marked for deactivation/deletion)
- has agreed to latest TOU/PP/GDPR.


Otherwise, send them to correct places.

=cut

sub check_user_status :Private {
  my ($self, $c, $args) = @_;

  $args  //= {};
  my $user = $c->user;
  my $skip_legal_check = $args->{skip_legal_check};

  unless ($user){
    $c->session->{alert_danger} = 'You need to login first.';
    $c->response->redirect($c->uri_for('/'),303);
    $c->detach;
  }

  # check if user has deactivated their account
  if($user->is_deactivated || $user->scheduled_delete_time){
    $c->response->redirect($c->uri_for('/reactivate'),303);
    $c->detach;
  }

  # Check if user has agreed to legal (tos/pp/gdpr)
  unless($skip_legal_check){
    # TODO
  }

}


=head2 my_profile

=cut

sub my_profile :Path('/my-profile') :Args(0) {
  my ($self, $c) = @_;

  # must be logged in + activated
  $c->forward('check_user_status',[{ skip_legal_check => 1 }]);

  $c->stash({
    template   => 'static/html/my-profile.html',
    active_tab => 'my-profile',
  });
}


=head2 my_assignment

=cut

sub my_assignment :Path('/my-assignment') :Args(0) {
  my ($self, $c) = @_;

  # must be logged in + activated + agreed to legal
  $c->forward('check_user_status');

  $c->stash({
    template   => 'static/html/my-assignment.html',
    active_tab => 'my-assignment',
  });
}


=head2 my_repos

=cut

sub my_repos :Path('/my-repos') :Args(0) {
  my ($self, $c) = @_;

  # must be logged in + activated + agreed to legal
  $c->forward('check_user_status');

  $c->stash({
    template   => 'static/html/my-repos.html',
    active_tab => 'my-repos',
  });
}

__PACKAGE__->meta->make_immutable;

1;
